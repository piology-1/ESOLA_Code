import json

from .Locks import Locks
from .PinLock import PinLock
from .Hardware import Hardware
from . import Util


class _Compartments:
    '''
        This class privides and manages all Data regarding the Compartments
    '''

    class _Compartment:
        '''
            This inner class holds Data specific to one Compartment
        '''

        def __init__(self, door, pos):
            self.door = int(door)
            self.pos = int(pos)

    def __init__(self):
        self._by_battery_type = {}  # create an empty dictionary for each battery type

        # Open the compartments JSON-file saved in the main curretn working directory
        with open(Util.datadir() + '/compartments.json') as f:
            for battery_type, buttons in json.load(f).items():
                if battery_type == '//':  # ignore all comments in the JSON file
                    continue

                # fill in the dictionary with the battery type
                self._by_battery_type[battery_type] = [self._Compartment(
                    door_pos[0], door_pos[1]) if door_pos and len(door_pos) == 2 else None for door_pos in buttons]

    def get_available(self, battery_type):  # Get all available battery types
        return [c and not Locks.is_present(c.door, c.pos)
                for c in self._by_battery_type[battery_type]]

    def get_occupied(self, battery_type):   # Get occupied battery types
        return [c and Locks.is_present(c.door, c.pos)
                for c in self._by_battery_type[battery_type]]

    # Sets the Pin for the specific door and opens the lock
    def pin_lock(self, battery_type, index, pin):
        c = self._by_battery_type[battery_type][index]
        if Locks.add(c.door, c.pos, PinLock(pin)):
            Hardware.rotate_to_position(c.pos)
            Hardware.open_door(c.door)
            return True
        return False

    # Removes the Pin for the specific door and opens the lock
    def pin_unlock(self, battery_type, index, pin):
        c = self._by_battery_type[battery_type][index]
        if Locks.attempt_unlock_and_remove(c.door, c.pos, pin):
            Hardware.rotate_to_position(c.pos)
            Hardware.open_door(c.door)
            return True
        return False


Compartments = _Compartments()  # this instance gets called in BackendBridge.py
