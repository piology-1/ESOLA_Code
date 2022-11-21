class Lock:

    _types = None
    _names = None

    @classmethod
    def _init_types(cls):
        # Wird von __init__ in Locks.py aus aufgerufen,
        # als Workaround für zirkulären Import.
        if not Lock._types:
            from .PinLock import PinLock
            Lock._types = {
                'pin': PinLock
            }
            Lock._names = {t: n for n, t in Lock._types.items()}

    @classmethod
    def from_dict(cls, d):
        try:
            if d['type'] in Lock._types:
                return Lock._types[d['type']].from_dict(d)
            else:
                raise NotImplementedError("lock type '%s'" % d['type'])
        except KeyError:
            raise ValueError("missing type")

    def to_dict(self):
        d = {
            'type': Lock._names[type(self)]
        }
        d.update(self._to_dict())
        return d

    def _to_dict(self):
        raise NotImplementedError

    def attempt_unlock(self, key):
        raise NotImplementedError
