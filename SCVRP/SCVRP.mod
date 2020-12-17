/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 17.10.2020 at 17:55:47
 *********************************************/
 
 int			n = ...;					//Count of nodes (including depot)
 {int}			V;							//Set of nodes (including depot)
 float			d[0..(n-1)];					//Demand of each customer
 {int} 			K		= ...;				//Set of vehicles
 float 			C 		= ...;				//Capacity of each vehicle
 {int}			emptySet;					//Helper to create empty sets in ILOG Script
 tuple			S {							//Subtour with set of customers and size of this tour
    int			size;
   	{int}		customers;
  };
 {S}			Subtours;					//Set which includes all subtours with to or more customers
 float 			coordinates [0..(n-1)][0..(n-1)];	//coordinates of every node
 int			c[0..(n-1)][0..(n-1)];				//Distance between every pair of nodes
 dvar boolean	x[V][V][K];					//decision variable
 
 minimize sum(i in V) sum(j in V) sum(k in K) c[i][j] * x[i][j][k];
 
 subject to {
	forall (i in V : i > 0)
	  sum(j in V)
	    sum(k in K)
	      x[i][j][k] == 1;
	forall (j in V : j > 0)
	  sum(i in V)
	    sum(k in K)
	      x[i][j][k] == 1;
	forall(k in K)
	  sum(i in V)
	    sum(j in V)
	      d[i] * x[i][j][k] <= C;
	forall(j in V : j > 0)
	  forall(k in K)
	    sum(i in V) x[i][j][k] - sum(i in V) x[j][i][k] == 0;
	forall(k in K)
	  sum(j in V : j > 0)
	    x[0][j][k] <= 1;
	forall(k in K)
	  sum(i in V : i > 0)
	    x[i][0][k] <= 1;
	forall(S in Subtours)
	  forall(k in K)
	    sum(i in S.customers)
	      sum(j in S.customers)
	        x[i][j][k] <= S.size - 1;
 }