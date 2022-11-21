import json

from .Lock import Lock
from . import Util


class _Locks:

    def __init__(self):
        Lock._init_types()
        self._persist_file = Util.datadir() + '/locks.json'
        self._persistence_paused = False
        self._locks = {}
        self._disk_restore()

    def add(self, door, pos, lock):
        if not door in self._locks:
            self._locks[door] = {}
        if pos in self._locks[door]:
            return False
        self._locks[door][pos] = lock
        self._on_modified()
        return True

    def is_present(self, door, pos):
        try:
            return bool(self._locks[door][pos])
        except:
            return False

    def attempt_unlock_and_remove(self, door, pos, key):
        self._persistence_paused = True
        success = self.attempt_unlock(door, pos, key)
        if success:
            self.remove(door, pos)
        self._persistence_paused = False
        self._on_modified()
        return success

    def attempt_unlock(self, door, pos, key):
        try:
            return self._locks[door][pos].attempt_unlock(key)
        except KeyError:
            return False

    def remove(self, door, pos):
        try:
            del(self._locks[door][pos])
            if not self._locks[door]:
                del(self._locks[door])
            self._on_modified()
            return True
        except KeyError:
            return False

    def _disk_restore(self):
        try:
            with open(self._persist_file) as f:
                for door, locks in json.load(f).items():
                    door = int(door)
                    self._locks[door] = {}
                    for pos, lock in locks.items():
                        self._locks[door][int(pos)] = Lock.from_dict(lock)
        except FileNotFoundError:
            pass

    def _disk_persist(self):
        with open(self._persist_file, 'w') as f:
            json.dump(self._locks, f, indent=2, default=lambda l: l.to_dict())
            f.write('\n')

    def _on_modified(self):
        if not self._persistence_paused:
            self._disk_persist()


Locks = _Locks()
