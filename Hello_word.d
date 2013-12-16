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
    QApplication app;   

    // Check the boot mode. If there is a '--debug' start in debug mode
    bool fDebug; fDebug = false; foreach (arg; args[0 .. args.length])  { if (arg=="--debug") fDebug = true; }
    // Download Qt graphics library
    int rez = LoadQt( dll.Core | dll.Gui | dll.QtE, fDebug); if (rez==1) return 1;  
    app = new QApplication; 
    (app.adrQApplication())(cast(void*)app.bufObj, &Runtime.cArgs.argc, Runtime.cArgs.argv, true);
    // ----------------------------------
    
    Exam ex = new Exam();
    ex.show();
    
    // The main body of the program ..
    
    // ----------------------------------
    return app.exec();
}
