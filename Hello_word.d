// ----- Pattern to work with QtE -----
// -----------------------------------
// 15.12.2013 15:01:02


import std.stdio;        // writeln
import core.runtime;     // Processing of input parameters 
import qte;              // work with Qt

class Exam: QMainWindow {
    this() {
		super();
	}

}

int main(string[] args) {
    // Test load library. '--debug' start in debug state.
    bool fDebug; foreach(arg; args) if (arg=="--debug") fDebug = true; 
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  // Error load QtE
    QApplication app = new QApplication(&Runtime.cArgs.argc, Runtime.cArgs.argv, 1);
    // ----------------------------------
    
    Exam ex = new Exam();
    ex.show();
    
    // The main body of the program ..
    
    // ----------------------------------
    return app.exec();
}
