//~ //System
//Externals
#include <Eigen/Dense>
#include <pthread.h>


//~ Custom Classes
//~ #include "PusherSlider.h"
//~ #include "Friction.h"
#include "Helper.h"
//~ #include "LinePusher.h"
//~ #include "StructuresOptProgram.h"

//~ #include "geometry_msgs/WrenchStamped.h"
//~ #include "PracticalSocket/PracticalSocket.h" // For UDPSocket and SocketException
//~ #include "egm.pb.h" // generated by Google protoc.exe
//~ #include "tf2_msgs/TFMessage.h"
//~ #include "tf/LinearMath/Transform.h"
//~ #include <ros/ros.h>
//~ #include "tf/tf.h"
//~ #include <tf/transform_datatypes.h>
//~ #include <tf/transform_listener.h>
//~ #include "geometry_msgs/Twist.h"
//~ #include "geometry_msgs/WrenchStamped.h"
//~ #include "std_msgs/String.h"

#ifndef LOOPCONTROL
#define LOOPCONTROL

extern pthread_mutex_t nonBlockMutex;

//~ using namespace abb::egm;
//~ using namespace tf;
using namespace std;
using Eigen::MatrixXd;

void *loopControl(void *thread_arg);
void initializeThread(void *thread_arg);


#endif  
