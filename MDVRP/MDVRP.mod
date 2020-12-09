/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 24.10.2020 at 14:15:22
 *********************************************/

 int	N = ...;						//Count of customers
 int	M = ...;						//Count of depots
 int	T = 100000;						//Maximum distance a vehicle can travel
 {int}	V;								//Set of nodes (customers and depots)
 {int}  K = ...;						//Set of vehicles
 float	C = ...;						//Capacity of each vehicle
 int	c[1..(N+M)][1..(N+M)];			//Distance between every pair of nodes
 float 	coordinates[1..(N + M)][0..1];	//Coordinates of each node
 float	d[1..(N+M)];					//demand of each node
 dvar boolean	x[V][V][K];				//Decision variable
 dvar int		y[V];					//Decision variable
 
 minimize sum(i in V) sum(j in V) sum (k in K) c[i][j] * x[i][j][k];
 
 subject to {
   forall(j in V : j <= N)
     sum(i in V)
       sum(k in K)
         x[i][j][k] == 1;
   forall(i in V : i <= N)
     sum(j in V)
       sum(k in K)
         x[i][j][k] == 1;
   forall(k in K)
     forall(h in V)
       (sum(i in V) x[i][h][k]) - (sum(j in V) x[h][j][k]) == 0;
   forall(k in K)
     sum(i in V) (d[i] * sum(j in V) x[i][j][k]) <= C;
   forall(k in K)
     sum(i in V)
       sum(j in V)
         c[i][j] * x[i][j][k] <= T;
   forall(k in K)
     sum(i in V : i > N)
       sum(j in V : j <= N)
         x[i][j][k] <= 1;
   forall(k in K)
     sum(j in V : j > N )
       sum(i in V : i <= N)
         x[i][j][k] <= 1;
   forall(i,j in V : i != j && j <= N && i <= N)
     forall(k in K)
       y[i]-y[j]+((N+M)*x[i][j][k]) <= N + M - 1;
 }