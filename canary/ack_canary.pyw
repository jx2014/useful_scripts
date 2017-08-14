import sys
import os
from PyQt4 import QtGui, QtCore
import time
import ctypes
import win32console

canaryAppId = 'CanaryChecker'
ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(canaryAppId)

warning_file = r'C:\TEMP\canary_device\WARNING_rf_contamination.canary'
alert_sound = 'alert.wav'

 
class Main(QtGui.QMainWindow):
 
    def __init__(self):
        QtGui.QMainWindow.__init__(self)
        self.initUI()
 
    def initUI(self):
 
        centralwidget = QtGui.QWidget(self)
        
                
        canary_icon = QtGui.QIcon()
        canary_icon.addFile('icons/canary_16.png', QtCore.QSize(16,16))
        canary_icon.addFile('icons/canary_24.png', QtCore.QSize(24,24))
        canary_icon.addFile('icons/canary_32.png', QtCore.QSize(32,32))
        canary_icon.addFile('icons/canary_48.png', QtCore.QSize(48,48))
        canary_icon.addFile('icons/canary_128.png', QtCore.QSize(128,128))
        canary_icon.addFile('icons/canary_256.png', QtCore.QSize(256,256))
         
        self.search_canary_timer = QtCore.QTimer(self)
        self.search_canary_timer.timeout.connect(self.SearchCanary)
        self.search_canary_timer.start(1000)
        
        self.alert_timer = QtCore.QTimer(self)
        self.alert_timer.timeout.connect(self.PlayAlert)
        
        self.alertSound = QtGui.QSound(alert_sound)
 
        self.ackBtn = QtGui.QPushButton("Acknowledge\nRF Contamination",self)
        self.ackBtn.clicked.connect(self.Ack)
        self.ackBtn.setDisabled(True)
        
        grid = QtGui.QGridLayout()
         
        grid.addWidget(self.ackBtn,1,0)
 
        centralwidget.setLayout(grid) 
        self.setCentralWidget(centralwidget)
        self.setWindowIcon(canary_icon)
        self.setWindowTitle('Canary RF Contamination Checker')
        self.setGeometry(200,200,450,80)
        self.setFixedHeight(80)
 
    def Ack(self):
        self.AckAction()
        self.ackBtn.setDisabled(True)
        self.alert_timer.stop()
        self.search_canary_timer.start(1000)
 
 
    def PlayAlert(self):
        self.alertSound.play()
     
    def SearchCanary(self):
        if os.path.exists(warning_file):
            self.ackBtn.setEnabled(True)
            self.search_canary_timer.stop()
            self.alert_timer.start(2000)
            ctypes.windll.user32.FlashWindow(win32console.GetConsoleWindow(), True )
    
    def AckAction(self):
        dn = os.path.dirname(warning_file)
        fn = os.path.basename(warning_file)
        fn_time = time.strftime("%m-%d-%Y_%H-%M-%S", time.localtime(time.time()))
        fn = '.'.join([fn, fn_time])
        new_file = os.path.join(dn, fn)
        os.rename(warning_file, new_file)
        
            
        
 
def main():
    app = QtGui.QApplication(sys.argv)
    main= Main()
    main.show()
 
    sys.exit(app.exec_())
 
if __name__ == "__main__":
    main()