/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 17.10.2020 at 17:55:47
 *********************************************/
 
 int			n = ...;					//Count of nodes (including depot)
 {int}			V;							//Set of nodes (including depot)
 float			d[0..n];					//Demand of each customer
 int 			K		= ...;				//Number of vehicles
 float 			C 		= ...;				//Capacity of each vehicle
 {int}			emptySet;					//Helper to create empty sets in ILOG Script
 tuple			S {							//Subtour with set of customers and cumulated demand of all customers in this tour
 	float		demand;
   	{int}		customers;
 }; 
 {S}			Subtours;					//Set which includes all subtours
 float 			coordinates [0..n][0..n];	//coordinates of every node
 int			c[0..n][0..n];				//Distance between every pair of nodes
 dvar boolean	x[V][V];					//decision variable
 
 minimize sum(i in V) sum(j in V) c[i][j] * x[i][j];
 
 subject to {
   forall (j in V : j > 0) sum(i in V) x[i][j] == 1;
   forall (i in V : i > 0) sum(j in V) x[i][j] == 1;
   sum(i in V) x[i][0] == K;
   sum(j in V) x[0][j] == K;
   forall (S in Subtours)
     sum(i in V : i not in S.customers)
       sum(j in S.customers)
         x[i][j] >= ceil(S.demand / C);
 }