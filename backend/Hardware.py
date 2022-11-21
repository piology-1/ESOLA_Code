class _Hardware:

    def __init__(self):
        try:
            from .RPiHardware import RPiHardware
            self._impl = RPiHardware()
        except:
            from .MockHardware import MockHardware
            self._impl = MockHardware()

    def open_door(self, door):
        return self._impl.open_door(door)

    def rotate_to_position(self, pos):
        return self._impl.rotate_to_position(pos)

Hardware = _Hardware()
