#include <QApplication>
#include <QDebug>
#include <QTimer>

#include "camera/camera.h"
#include "camera/flowmanager.h"
#include "camera/flowconnection.h"
#include "cameracom.h"

#include <QSignalSpy>

class SleeperThread : public QThread
{
    public:
    static void msleep(unsigned long msecs)
    {
        QThread::msleep(msecs);
    }
};

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // load camera config file (node_generated.xml)
    if(a.arguments().size()<2)
    {
        qDebug()<<"Please specify node_generated.xml as first argument";
        return 1;
    }
    QString configFileName = a.arguments()[1];
    qDebug()<<configFileName;
    Camera cam(configFileName);
    if(!cam.node())
    {
        qDebug()<<"Invalid node_generated.xml file";
        return 1;
    }

    // check for available camera, if present, connect to the first one
    QVector<CameraInfo> avaibleCams = CameraCom::avaibleCams();
    if(avaibleCams.empty())
    {
        qDebug()<<"No camera available";
        return 1;
    }
    cam.connectCam(avaibleCams[0]);
    qDebug()<<"connected to camera"<<avaibleCams[0].driverType()<<avaibleCams[0].addr();
    SleeperThread::msleep(500);
    cam.registermanager().evalAll();
//    int select_val=1;
    for(int select_val=0;select_val<16;select_val++){

//        // Set Param
        cam.rootProperty().path("lenet5.Selection")->setValue(select_val);

        SleeperThread::msleep(500);
        cam.registermanager().evalAll();

//        // Output image name
        QString targetFilename = "/home/kamel/dev/demo-dloc/img/feature";
        targetFilename = targetFilename + QString::number(select_val) + ".png";

//        // send image
        QImage image("/home/kamel/dev/demo-dloc/img/sample.png");
        cam.com()->outputFlow()[1]->send(image);
        qDebug()<<"Sent Image";

        QSignalSpy spy(cam.com(), SIGNAL(flowReadyToRead(int)));
        qDebug()<<spy.wait(500);

//        // save result
        cam.flowManager()->flowConnection(129)->lastData().toImage(QSize(79,79), 8)->save(targetFilename); // usb.in1
     }

    return a.exec();
}
