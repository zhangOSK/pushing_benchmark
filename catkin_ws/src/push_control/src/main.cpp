//~ //System
#include <iostream>
#include <stdio.h>
#include <time.h>
#include <cmath>
#include <math.h>
//Externals
#include <Eigen/Core>
#include "json/json.h"
//~ Custom Classes
#include "StructuresMain.h"
#include "PointPusher.h"
#include "LinePusher.h"
#include "Helper.h"
#include "push_control/rosbag.h"
//Ros
#include <ros/ros.h>
#include "tf/tf.h"
#include <tf/transform_datatypes.h>
#include <tf/transform_listener.h>
#include "geometry_msgs/Twist.h"
#include "std_msgs/String.h"
#include "std_msgs/Float64.h"
#include "std_msgs/Float64MultiArray.h"
#include "std_srvs/Empty.h"
#include <unistd.h>

//ABB Robot
#include "ABBRobot.h"
#include "PracticalSocket/PracticalSocket.h" // For UDPSocket and SocketExAeqption
#include "egm/egm.pb.h" // generated by Google protoc.exe
//Define shortcuts

using namespace std;
using namespace Eigen;

//*********************** Global variables *************************************
pthread_mutex_t nonBlockMutex;
//*********************** Main Program *************************************
int main(int argc,  char *argv[]){
  cout<< "[main] Start Program" <<endl;

  //~Ros parameters
  ros::init(argc, argv, "push_control");
  ros::NodeHandle n1;
  tf::TransformListener listener;
  bool is_exit=false;
  n1.setParam("is_exit", false);

  /* ********************************** */
  /*    Load parameters from JSON file  */
  /* ********************************** */
  Json::Value root;
  Json::Reader reader;
  char const* tmp = getenv( "PUSHING_BENCHMARK_BASE" );
  string envStr( tmp );
  string file_parameters;
  file_parameters = envStr + "/catkin_ws/src/push_control/src/control_parameters.json";
  cout<<file_parameters<<endl;
  ifstream file(file_parameters);
  file >> root;
  int steps_mpc;
  double h_mpc;
  int controller_flag; //0:FOM, 1: Hybrid, 2: Data
  Helper::write_int_JSON(root["Parameters"]["steps_mpc"], steps_mpc);
  Helper::write_int_JSON(root["Parameters"]["controller_flag"], controller_flag);
  Helper::write_double_JSON(root["Parameters"]["h_mpc"], h_mpc);

  int num_uc;
  if (controller_flag==2){
    num_uc = 2;
  }else{
    num_uc=3;
  }

  //specified json paths
  string trajectory_name = root["Parameters"]["trajectory_filename"].asString();
  string experiment_name = trajectory_name + root["Parameters"]["save_data_filename"].asString();

  //Define system objects on pusher type
  PusherSlider pusher_slider;
  Friction friction(&pusher_slider);
  PointPusher point_pusher(&pusher_slider, &friction, trajectory_name, num_uc);
  //  LinePusher line_pusher(&pusher_slider, &friction, trajectory_name, 5);    //Variable to pass to thread
  Pusher * ppusher = &point_pusher;
//   Pusher * ppusher = &line_pusher;

  MatrixXd Q = MatrixXd::Zero(ppusher->numxcStates, ppusher->numxcStates);
  MatrixXd Qf = MatrixXd::Zero(ppusher->numxcStates, ppusher->numxcStates);
  MatrixXd R = MatrixXd::Zero(ppusher->numucStates, ppusher->numucStates);
  VectorXd Q_diag = VectorXd::Zero(ppusher->numxcStates);
  VectorXd Qf_diag = VectorXd::Zero(ppusher->numxcStates);
  VectorXd R_diag = VectorXd::Zero(ppusher->numucStates);
  double Q_scale;
  double Qf_scale;
  double R_scale;

  Helper::write_vector2_JSON(root["Parameters"]["Q"], Q_diag);
  Helper::write_vector2_JSON(root["Parameters"]["Qf"], Qf_diag);
  Helper::write_vector2_JSON(root["Parameters"]["R"], R_diag);
  Helper::write_double_JSON(root["Parameters"]["Q_scale"], Q_scale);
  Helper::write_double_JSON(root["Parameters"]["Qf_scale"], Qf_scale);
  Helper::write_double_JSON(root["Parameters"]["R_scale"], R_scale);
//  int N_star = ppusher->t_star.size();

  Q.diagonal() = Q_scale*Q_diag;
  Qf.diagonal() = Qf_scale*Qf_diag;
  R.diagonal() = R_scale*R_diag;
  cout<<Q<<endl;
  cout<<Qf<<endl;
  cout<<R<<endl;
//  int N_star = ppusher->t_star.size();
//  cout<<N_star<<endl;
//  cout<<ppusher->t_star(ppusher->t_star.size()-1)<<endl;

//  cout<<ppusher->t_star(N_star)<<endl;
//  cout<<N_star<<endl;

  //FOM control parameters
//    Q.diagonal() << 3,3,.1,0.0;Q=Q*10;
//    Qf.diagonal() << 3,3,.1,0.0;Qf=Qf*2000;
//    R.diagonal() << 1,1,0.01;R = R*.01;
  //Hybrid control parameters
//  Q.diagonal() << 3,3,.1,0.0;Q=Q*10;
//  Qf.diagonal() << 3,3,.1,0.0;Qf=Qf*2000;
//  R.diagonal() << 1,1,0.01;R = R*.01;
  //GPDataController control parameters
//  Q.diagonal() << 1,1,.01,1;Q=Q*100;
//  Qf.diagonal() << 1,1,.1,1;Qf=Qf*1000;
//  R.diagonal() << 1,.1;R = R*.1;
  //LMODES control parameters
//    Q.diagonal() << 3,3,.1,0.0;Q=Q*10;
//    Qf.diagonal() << 3,3,.1,0.0;Qf=Qf*2000;
//    R.diagonal() << 1,1,0.01;R = R*.5;
//  steps_mpc = 35;
//  h_mpc = 0.03; //use .01 for GPDataController
  /* ********************************** */

  /* ********************** */
  /*    Data Saving Setup  */
  /* ********************* */

  //Define rosservices
  ros::ServiceClient start_rosbag = n1.serviceClient<push_control::rosbag>("start_rosbag");
  ros::ServiceClient stop_rosbag = n1.serviceClient<push_control::rosbag>("stop_rosbag");

  //Define publishers
  ros::Publisher exec_joint_pub = n1.advertise<sensor_msgs::JointState>("/joint_states", 2);
  ros::Publisher xc_pub = n1.advertise<std_msgs::Float64MultiArray>("/xc", 2);
  ros::Publisher uc_pub = n1.advertise<std_msgs::Float64MultiArray>("/uc", 2);
  ros::Publisher us_pub = n1.advertise<std_msgs::Float64MultiArray>("/us", 2);
  ros::Publisher q_pusher_sensed_pub = n1.advertise<std_msgs::Float64MultiArray>("/q_pusher_sensed", 2);
  ros::Publisher q_pusher_commanded_pub = n1.advertise<std_msgs::Float64MultiArray>("/q_pusher_commanded", 2);
  ros::Publisher time_pub = n1.advertise<std_msgs::Float64>("/time", 2);

  //initialize rosbag
  push_control::rosbag srv;
  srv.request.input =  experiment_name;

  //Doubles
  double  time=0, t_ini,_time;
  double h=1.0f/1000;
  double joint6 = 1.51;

  //VectorsMatrixXd
  Vector3d q_slider; //pose of object
  Vector3d q_pusher; //pose of pusher
  Vector3d twist_pusher; //commanded twist of pusher [dx,dy,dtheta]
  Vector3d _q_slider; //pose of object
  Vector3d _q_pusher; //pose of pusher
  Vector3d _twist_pusher; //commanded twist of pusher [dx,dy,dtheta]
  Vector3d q_pusher_sensor; //pose of pusher
  VectorXd xc(ppusher->numxcStates);
  VectorXd uc(ppusher->numucStates);
  VectorXd xs(ppusher->numxsStates);
  VectorXd us(ppusher->numusStates);
  VectorXd xc_des(ppusher->numxcStates);
  VectorXd uc_des(ppusher->numucStates);
  VectorXd xs_des(ppusher->numxsStates);
  VectorXd us_des(ppusher->numusStates);
  VectorXd joint_states(6);
  VectorXd q0(6);

  //Read JSON file
  Json::StyledWriter styledWriter;
  Json::Value JsonOutput;
  Json::Value timeJSON;
  Json::Value q_pusher_sensedJSON;
  Json::Value q_pusher_commandedJSON;
  Json::Value xc_JSON;
  Json::Value xs_JSON;
  Json::Value uc_JSON;
  Json::Value us_JSON;
  Json::Value xc_desired;
  Json::Value xs_desired;
  Json::Value uc_desired;
  Json::Value us_desired;
  Json::Value Q_JSON;
  Json::Value Qf_JSON;
  Json::Value R_JSON;
  Json::Value steps_mpc_JSON;
  Json::Value h_mpc_JSON;

//Variable to pass to thread
  thread_data thread_data_array;
  thread_data_array.q_slider = &q_slider;
  thread_data_array.q_pusher = &q_pusher;
  thread_data_array.twist_pusher = &twist_pusher;
  thread_data_array.time = &time;
  thread_data_array.xc = &xc;
  thread_data_array.xs = &xs;
  thread_data_array.uc = &uc;
  thread_data_array.us = &us;
  thread_data_array.xc_des = &xc_des;
  thread_data_array.xs_des = &xs_des;
  thread_data_array.uc_des = &uc_des;
  thread_data_array.us_des = &us_des;
  thread_data_array.Q = &Q;
  thread_data_array.Qf = &Qf;
  thread_data_array.R = &R;
  thread_data_array.steps = &steps_mpc;
  thread_data_array.h = &h_mpc;
  thread_data_array.controller_flag = &controller_flag;
  thread_data_array.ppusher = ppusher;

  robotStruct robot_struct;
  bool isRobot;
  bool is_success;
  bool isExecute=true;
  //~ n1.getParam("have_robot", isExecute);
  n1.getParam("have_robot", isRobot);

  //initialize values
  joint_states << 0,0,0,0,0,0;
  q0 << 0,0,0,0,0,0;

  //************** Initialization Loops ****************************************************************************************
  //First Loop (Check Vicon, Robot connection, ros)
  if (isExecute && ros::ok()) {

    if (isRobot) {
        initializeVicon(q_slider, listener);
//        cout<<q_slider<<endl;
//        return 0;
        initializeEGM(robot_struct, q_pusher, joint_states);
        }
    initializeThread((void *) &thread_data_array);


    if (isRobot) {
      pauseEGM(robot_struct, 2, joint_states);
      //---------------Protected----------------
      pthread_mutex_lock(&nonBlockMutex);
      //Intermediate communication step (required)
      if (getRobotPose(robot_struct.EGMsock, robot_struct.sourceAddress, robot_struct.sourcePort,
                       robot_struct.pRobotMessage, q_pusher, joint_states)) {
        _q_pusher(0) = q_pusher(0);
        _q_pusher(1) = q_pusher(1);
        _q_pusher(2) = q_pusher(2);
      }

      pthread_mutex_unlock(&nonBlockMutex);
    }
    else{
          time = 3.5;
//          cout<<"time"<<_time<<endl;
          _time = time;
          q_slider(0) = 0.3484033942222595;
          q_slider(1) = 0.02;
          q_slider(2) = 0.3; //0.3
          q_pusher << .3484033942222595-0.0318, -0.0118, 0.3;
    }
    
    if (isRobot){
        start_rosbag.call(srv);
    }
    //************** Main Control Loop ****************************************************************************************
    ros::Rate r(1000);
    int i=0;

    while(ros::ok()) {
    n1.getParam("is_exit", is_exit);
    if (is_exit==true){
      break;
    }

      //get time
      if (i == 0) { t_ini = Helper::gettime(); }

      //read robot pusher position
      if (getRobotPose(robot_struct.EGMsock, robot_struct.sourceAddress, robot_struct.sourcePort,
                       robot_struct.pRobotMessage, q_pusher_sensor, joint_states)) {
      }
      //-------Protected---------------------
      pthread_mutex_lock(&nonBlockMutex);

      //define simulation time
      time = Helper::gettime() - t_ini;
      _time = time;
      if (isRobot) {
          getViconPose(q_slider, listener);
          q_pusher = _q_pusher;
//        cout<<q_slider<<endl;
//        return 0;
      }
      else {
          time = 3.5;
//          cout<<"time"<<_time<<endl;
          _time = time;
          q_slider(0) = 0.3484033942222595;
          q_slider(1) = 0.02;
          q_slider(2) = 0.3;
          q_pusher << .3484033942222595-0.0318, -0.0118, 0.3;

      }

      //read twist_pusher FROM thread
      _twist_pusher = twist_pusher;
//      if (ppusher->num_contact_points==1){
//        velocityOffsetABB(_q_pusher, _twist_pusher, 0.05, -0.15, ppusher->d);
//      }

      //publish messages
      publish_float64_array(q_pusher_sensor, q_pusher_sensed_pub);
      publish_float64_array(_q_pusher, q_pusher_commanded_pub);
      publish_float64_array(xc, xc_pub);
      publish_float64_array(uc, uc_pub);
      publish_float64_array(us, us_pub);
      publish_float64(time, time_pub);

      // Update JSON Arrays
      timeJSON.append(time);

      //q_pusher sensed
      for (int j =0;j<3;j++){q_pusher_sensedJSON[j].append(q_pusher_sensor(j));}
      for (int j =0;j<3;j++){q_pusher_commandedJSON[j].append(_q_pusher(j));}
      for (int j =0;j<ppusher->numucStates;j++){uc_JSON[j].append(uc(j));}
      for (int j =0;j<ppusher->numusStates;j++){us_JSON[j].append(us(j));}
      for (int j =0;j<ppusher->numxcStates;j++){xc_JSON[j].append(xc(j));}
      for (int j =0;j<ppusher->numxsStates;j++){xs_JSON[j].append(xs(j));}

      for (int j =0;j<ppusher->numucStates;j++){uc_desired[j].append(uc_des(j));}
      for (int j =0;j<ppusher->numusStates;j++){us_desired[j].append(us_des(j));}
      for (int j =0;j<ppusher->numxcStates;j++){xc_desired[j].append(xc_des(j));}
      for (int j =0;j<ppusher->numxsStates;j++){xs_desired[j].append(xs_des(j));}



      pthread_mutex_unlock(&nonBlockMutex);
      //-----------------------------------
      if (_time> ppusher->t_star(ppusher->t_star.size()-1)){
        break;
      }

      // Send veloAinty commands
//            _twist_pusher << 0.05,0.01,0;
              _twist_pusher(2) = 0;
      if (isRobot) {
//        cout<<"twist_pusher"<<endl;
          velocityControlABB(robot_struct, _q_pusher, _twist_pusher, h);
          publish_joints(joint_states, exec_joint_pub);
      }
      else {
//        _q_pusher = _q_pusher + h*_twist_pusher;
//        ikfast_pusher(_q_pusher, joint_states, q0, is_success, listener);
//        publish_joints(joint_states, exec_joint_pub);

      }
      //Sleep for 1000Hz loop
      r.sleep();
      i++;
    }
  }
  else{
    cout << "[main][warning] isExecute set to false and/or ros!=ok"<<endl;
  }
  
  if (isRobot){

      //save json variables
      for (int j =0;j<ppusher->numxcStates;j++){Q_JSON[j].append(Q(j,j));}
      for (int j =0;j<ppusher->numxcStates;j++){Qf_JSON[j].append(Qf(j,j));}
      for (int j =0;j<ppusher->numucStates;j++){R_JSON[j].append(R(j,j));}
      for (int j =0;j<1;j++){h_mpc_JSON[j].append(h_mpc);}
      for (int j =0;j<1;j++){steps_mpc_JSON[j].append(steps_mpc);}
      // Save JSON Output file
      JsonOutput["timeJSON"] = timeJSON;
      JsonOutput["q_pusher_sensed"] = q_pusher_sensedJSON;
      JsonOutput["q_pusher_commanded"] = q_pusher_commandedJSON;
      JsonOutput["xc"] = xc_JSON;
      JsonOutput["xs"] = xs_JSON;
      JsonOutput["uc"] = uc_JSON;
      JsonOutput["us"] = us_JSON;
      JsonOutput["xc_desired"] = xc_desired;
      JsonOutput["xs_desired"] = xs_desired;
      JsonOutput["uc_desired"] = uc_desired;
      JsonOutput["us_desired"] = us_desired;
      JsonOutput["Q"] = Q_JSON;
      JsonOutput["Qf"] = Qf_JSON;
      JsonOutput["R"] = R_JSON;
      JsonOutput["h_mpc"] = h_mpc_JSON;
      JsonOutput["steps_mpc"] = steps_mpc_JSON;

      ofstream myOutput;
      string src_path = getenv("PUSHING_BENCHMARK_BASE");
    //  string fileName  = src_path + "/catkin_ws/src/push_control/src/Data/8Track_line_pusher_radius_0_15_vel_0_05_exp_fom_perturb_2.json";
      string fileName  = src_path + "/catkin_ws/src/push_control/src/Data/"+ experiment_name + ".json";
      myOutput.open (fileName);
      myOutput << styledWriter.write(JsonOutput);
      myOutput.close();

      //terminate rosbag
      stop_rosbag.call(srv);
    }
  cout<< "[main] End of Program" <<endl;
}
