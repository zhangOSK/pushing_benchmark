//
// Created by mcube10 on 5/8/17.
//

#include "StructuresOptProgram.h"
#include "StructuresMain.h"
#include "MPC.h"
#include "FOM.h"
#include "LinePusher.h"
#include <unistd.h>

typedef SparseMatrix<double> SparseMatrixXd;

FOM::FOM(int _num_families,PusherSlider *_pusher_slider, Pusher *_line_pusher, Friction *_friction, MatrixXd Q, MatrixXd Qf, MatrixXd R, double _h, int _steps) {
    line_pusher = _line_pusher;
    num_families=_num_families;
    friction=_friction;
    pusher_slider=_pusher_slider;
    numucStates=_line_pusher->numucStates;

    for (int lv1=0;lv1<num_families;lv1++){
//        out_matrices = readMatrices(lv1);

        controller = new MPC(_pusher_slider, _line_pusher, _friction,  Q,  Qf, R, _h, _steps);
        list_controller[lv1] = controller;

        out_solution = new outSolutionStruct;
        list_out_solution[lv1] = out_solution;

        thread_data_array = new MPC_thread_data;
        thread_data_array->controller = list_controller[lv1];
        thread_data_array->out_solution = list_out_solution[lv1];

//        list_controller[lv1]->initializeMatricesMPC();
//        list_controller[lv1]->buildWeightMatrices();
        thread_data_list[lv1] = thread_data_array;

    }
}

VectorXd FOM::solveMPC(VectorXd xc, double time){

    //Initialize variables
    VectorXd objList(num_families);
    VectorXd delta_xc(xc.rows());
    VectorXd mode_schedule(list_controller[0]->steps);

    delta_xc = line_pusher->getError(xc, time);
//    cout<<"delta_xc"<<delta_xc<<endl;
//    cout<<"xc"<<xc<<endl;


    for (int i=0;i<num_families;i++){
        mode_schedule << i, VectorXd::Zero(list_controller[i]->steps-1);
        thread_data_list[i]->delta_xc = delta_xc;
        thread_data_list[i]->time = time;
        thread_data_list[i]->mode_schedule = mode_schedule;
        thread_data_list[i]->is_gp = false;
    }

    //Find state error at current time
    delta_xc = line_pusher->getError(xc, time);
    outStateNominal out_state_nominal;
    out_state_nominal = line_pusher->getStateNominal(time);

//  cout<<"xc_star"<<out_state_nominal.xcStar<<endl;
//  cout<<"uc_star"<<out_state_nominal.ucStar<<endl;
    //create threads (and run controllers in parallel)
    for (int i=0;i<num_families;i++){
        pthread_create(&my_thread[i], NULL, &MPC_thread, (void *)  thread_data_list[i]);
    }

    //wait for all programs to terminate
    for (int i=0;i<num_families;i++){
        pthread_join(my_thread[i], NULL);
        objList(i) = list_controller[i]->out_solution.objVal;
//      cout<<"delta_u "<<i<<endl<<list_controller[i]->out_solution.solution<<endl;
    }

    //Find minimum objective value
    MatrixXf::Index   minIndex;
    double minVal = objList.minCoeff(&minIndex);
    cout<<"Mode selected: "<<minIndex<<endl;
    VectorXd delta_uc = list_controller[minIndex]->out_solution.solution;
    VectorXd uc = delta_uc + out_state_nominal.ucStar;

    return uc;

}

VectorXd FOM::get_robot_velocity(VectorXd xc, VectorXd uc) {

    return line_pusher->force2Velocity(xc, uc);
}
