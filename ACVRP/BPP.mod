/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 23.10.2020 at 11:22:12
 *********************************************/


 int 			n = ...;		//Number of nodes (including depot)
 {int}			V;				//Set of nodes (including depot)
 float			C		= ...;	//Capacity of each vehicle
 float			d[0..n];		//demand of each node
 dvar boolean	Y[V];			//Decision variable, 1 if vehicle i is ised
 dvar boolean	X[V][V];		//Decision variable, 1 if node i is served by vehicle j
 
 minimize sum(j in V) Y[j];
 	
 subject to {
    forall(i in V)
      sum(j in V)
        d[j] * X[i][j] <= C * Y[i];
    forall(j in V)
      sum(i in V)
        X[i][j] == 1;
 }