import os
import sys


'''
    Helper Modul 
'''

_datadir = None


def datadir():
    '''
        This function gets the Path to the current main directory, where all the files are located
    '''
    global _datadir  # _datadir is None
    if _datadir is None:
        try:
            # sys.modules returns a dictionary with a module as a key and the Path as the value (https://docs.python.org/3/library/sys.html)
            # returns the path, where the file is located, which calls the function from the beginning (Path of Directory, where gui_main.py is located)
            _datadir = os.path.dirname(sys.modules['__main__'].__file__)
            print("try block: "+_datadir)
        except:
            _datadir = os.getcwd()  # returns current working directory
            print("except block: "+_datadir)
    return _datadir
