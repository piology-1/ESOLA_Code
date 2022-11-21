#!/usr/bin/env python

# getting Qt Installer from: https://download.qt.io/official_releases/online_installers/

# python-3.10 -m pip install PySide2
# https://pypi.org/project/PySide2/ : PySide2 for Python Version from Python >=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, !=3.4.*, <3.11
# https://www.python.org/ftp/python/3.10.8/python-3.10.8-amd64.exe in Browser downloads the installer for Vorseion: Python3.10.8 (make shure Path is clicked!)

# Helpfull reagrding PySide6 and QML (backend stuff etc): https://www.pythonguis.com/tutorials/pyside6-qml-qtquick-python-application/


'''
    With PySide6 the Program is not working properly
    
    Errors:
    QQmlApplicationEngine failed to load component
    file:///C:/Users/piusg/OneDrive/Studienarbeit_ESOLA/03_Programmcode/Test_Repo/Solartankstelle.qml:11:5: Type App unavailable
    file:///C:/Users/piusg/OneDrive/Studienarbeit_ESOLA/03_Programmcode/Test_Repo/qml/App.qml:3:1: Type AppScreen unavailable
    file:///C:/Users/piusg/OneDrive/Studienarbeit_ESOLA/03_Programmcode/Test_Repo/qml/AppScreen.ui.qml:21:5: Type TopBar unavailable
    file:///C:/Users/piusg/OneDrive/Studienarbeit_ESOLA/03_Programmcode/Test_Repo/qml/TopBar.ui.qml:28:5: Type ImageButton unavailable
    file:///C:/Users/piusg/OneDrive/Studienarbeit_ESOLA/03_Programmcode/Test_Repo/qml/ImageButton.ui.qml:2:1: module "Qt5Compat.GraphicalEffects" is not installed

    So the Issue is caused by a function named "ColorOverlay" in the qml source code at ImageButton.ui.qml
'''

import os
import sys
from pathlib import Path

from PySide6.QtCore import QObject, QUrl
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QGuiApplication

from backend.BackendBridge import BackendBridge


# getting the path of the current main directory with all the files
CURRENT_DIRECTORY = Path(__file__).resolve().parent


def initQML() -> None:  # return value: None

    app = QGuiApplication(sys.argv)  # Create an App Oject
    qmlengine = QQmlApplicationEngine()  # Create a qml engine
    qmlengine.quit.connect(app.quit)

    # whole path to Solartankstelle.qml
    main_qml_file_path = os.fspath(CURRENT_DIRECTORY / "Solartankstelle.qml")
    file_url = QUrl.fromLocalFile(main_qml_file_path)

    try:
        # Load QML Data from "Solartankstelle.qml"
        qmlengine.load(file_url)
        # qmlengine.load("Solartankstelle.qml")
        # qmlengine.load(main_qml_file_path)
    except:
        raise Exception("QQmlApplicationEngine failed to load component")

    # Returns a list of all the root objects instantiated by the QQmlApplicationEngine
    root_objects = qmlengine.rootObjects()
    print(f"QML Engine: {root_objects}")
    if len(root_objects) == 0:  # check whether the list of rootObjects is empty or not
        quit()

    # getting the rootObject; type: QObject
    qmlApplicationWindow = root_objects[0]

    qmlApp = qmlApplicationWindow.findChild(
        QObject, "app")  # Find the target object

    # Set the properties with backendBridge
    qmlApp.setProperty('BackendBridge', BackendBridge)

    sys.exit(app.exec_())  # close the GUI properly


if __name__ == "__main__":
    initQML()


################################################################
# def handle_object_created(obj, obj_url):
    #     if obj is None and file_url == obj_url:
    #         QCoreApplication.exit(-1)
    #     else:
    #         root = qmlengine.rootObjects()[0]

    # qmlengine.objectCreated.connect(handle_object_created, Qt.QueuedConnection)
