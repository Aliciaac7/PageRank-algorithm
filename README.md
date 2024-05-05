# DESCRIPTION:
This project contains functions that implement the PageRank algorithm in Racket. PageRank, a renowned graph algorithm, is widely employed in information retrieval and was initially popularized as the algorithm fueling the Google search engine.

# FEATURES:
- Graph Verification: The graph? function verifies whether the provided input conforms to the structure of a graph, ensuring that each element of the list represents a link between two pages.
- PageRank Validation: The pagerank? function checks whether the input is a valid representation of PageRank, ensuring that it conforms to certain requirements such as being a hash-map with symbols as keys and rational numbers as values, and that the sum of all values equals 1.
- Graph Analysis Functions: Functions like num-pages, num-links, and get-backlinks provide capabilities to analyze properties of the graph, such as counting the number of pages, determining the number of links emanating from a page, and finding backlinks to a specific page.
- PageRank Computation: The mk-initial-pagerank, step-pagerank, and iterate-pagerank-until functions perform the actual computation of PageRank. They generate initial PageRank values, iterate through the PageRank algorithm steps, and converge to the final PageRank values based on specified criteria.
- Helper Functions: Helper functions such as maximum-difference and pagerank-converged? aid in the process of iterating PageRank until convergence.
- Page Ranking: The rank-pages function ranks pages based on their PageRank values, providing a list of pages in ranked order from least to most popular.

# IMPLEMENTATION:
- use the code in `testing-facilities.rkt` to help generate test input graphs for the project. The test suite was generated using those functions.
- Funtions used:
    - [graph?]  
    - [pagerank?]
    - [num-pages]
    - [num-links]
    - [get-backlinks]
    - [mk-initial-pagerank]
    - [step-pagerank]
    - [iterate-pagerank-until]
    - [rank-pages]

# INSTALLATION:
- This project runs the tests in Python, but the code uses Racket so make sure to have both installed
- If you run tester.py file the program will start running the tests available to
check that the Pagerank project is working
- Make sure to run the file and add this to the terminal " -a -v "
