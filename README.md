# Betweenness Centrality for Large Graphs
 Betweenness centrality is a measure of the influence of a vertex over the flow of information between every pair of vertices under the assumption that information primarily flows over the shortest paths between them.

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Graph_betweenness.svg/1200px-Graph_betweenness.svg.png" alt="Betweenness Centrality" width="200"/>

We didn't realize when we first looked at the problem statement, but BC has loads of applications. For example, 
1. Betweenness centrality is used to identify influencers in legitimate, or criminal, organizations. Studies show that influencers in organizations are not necessarily in management positions, but instead can be found in brokerage positions of the organizational network. Removal of such influencers could seriously destabilize the organization. 
2. Betweenness centrality can be used to help microbloggers spread their reach on Twitter, with a recommendation engine that targets influencers that they should interact with in the future.


### Results
**GPU Used -** Nvidia Tesla K80 (through Google Colab)
**CPU Used -** Intel core-i5 8250

<sub><sup>Execution times were measured using the time.h library and the values below are in seconds.</sup></sub>

|      Input Size          |GPU Time                          |CPU                         |
|----------------|-------------------------------|-----------------------------|
|10^3|0.008973            |2.16074            |
|10^4          |26.391409            |296.771326            |
|10^5          |2635.802207| N/A|


