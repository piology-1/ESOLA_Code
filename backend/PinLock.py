from .Lock import Lock


class PinLock(Lock):

    def __init__(self, pin):
        self._pin = str(pin)

    @classmethod
    def from_dict(cls, d):
        return PinLock(d['pin'])

    def _to_dict(self):
        return {
            'pin': self._pin
        }

    def attempt_unlock(self, key):
        return self._pin == str(key)
