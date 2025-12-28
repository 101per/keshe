/**
 * 图数据结构及最小生成树算法实现
 */
export class Graph {
  private cityNames: string[] = [];
  private adjacencyMatrix: number[][] = [];

  constructor(cityNames?: string[], matrix?: number[][]) {
    if (cityNames && matrix) {
      this.initialize(cityNames, matrix);
    }
  }

  /**
   * 初始化图
   * @param cityNames 城市名称数组
   * @param matrix 邻接矩阵
   */
  initialize(cityNames: string[], matrix: number[][]): void {
    if (cityNames.length !== matrix.length || matrix.some(row => row.length !== matrix.length)) {
      throw new Error("Invalid matrix dimensions");
    }
    
    this.cityNames = [...cityNames];
    this.adjacencyMatrix = matrix.map(row => [...row]);
  }

  /**
   * 获取城市名称列表
   */
  getCityNames(): string[] {
    return [...this.cityNames];
  }

  /**
   * 获取邻接矩阵
   */
  getAdjacencyMatrix(): number[][] {
    return this.adjacencyMatrix.map(row => [...row]);
  }

  /**
   * 设置邻接矩阵值
   * @param i 行索引
   * @param j 列索引
   * @param value 权重值
   */
  setEdge(i: number, j: number, value: number): void {
    if (i >= 0 && i < this.adjacencyMatrix.length && j >= 0 && j < this.adjacencyMatrix.length) {
      this.adjacencyMatrix[i][j] = value;
      this.adjacencyMatrix[j][i] = value; // 保证对称性
    }
  }

  /**
   * 获取边的权重
   * @param i 起始节点索引
   * @param j 结束节点索引
   * @returns 权重值
   */
  getEdge(i: number, j: number): number {
    if (i >= 0 && i < this.adjacencyMatrix.length && j >= 0 && j < this.adjacencyMatrix.length) {
      return this.adjacencyMatrix[i][j];
    }
    return Infinity;
  }

  /**
   * 获取节点数量
   */
  getNodeCount(): number {
    return this.cityNames.length;
  }

  /**
   * Prim算法实现最小生成树
   * @param start 起始节点索引，默认为0
   * @returns MST结果 {edges: 边数组, cost: 总代价}
   */
  prim(start: number = 0): { edges: { from: number, to: number, weight: number }[], cost: number } {
    // 该算法已完整实现，如需调整优先队列方式或细节，可在此修改
    const n = this.getNodeCount();
    if (n === 0) return { edges: [], cost: 0 };

    const visited: boolean[] = new Array(n).fill(false);
    const edges: { from: number, to: number, weight: number }[] = [];
    let totalCost = 0;

    visited[start] = true;
    let current = start;

    // 添加n-1条边
    for (let i = 0; i < n - 1; i++) {
      let minWeight = Infinity;
      let nextNode = -1;
      let sourceNode = -1;

      // 查找与当前MST相连的最小权重边
      for (let u = 0; u < n; u++) {
        if (visited[u]) {
          for (let v = 0; v < n; v++) {
            if (!visited[v] && this.getEdge(u, v) < minWeight) {
              minWeight = this.getEdge(u, v);
              nextNode = v;
              sourceNode = u;
            }
          }
        }
      }

      if (nextNode !== -1) {
        visited[nextNode] = true;
        edges.push({ from: sourceNode, to: nextNode, weight: minWeight });
        totalCost += minWeight;
        current = nextNode;
      }
    }

    return { edges, cost: totalCost };
  }

  /**
   * Kruskal算法实现最小生成树
   * @returns MST结果 {edges: 边数组, cost: 总代价}
   */
  kruskal(): { edges: { from: number, to: number, weight: number }[], cost: number } {
    // 该算法已完整实现，如需调整优先队列方式或细节，可在此修改
    
    // 并查集类定义
    class UnionFind {
      private parent: number[];
      
      constructor(size: number) {
        this.parent = Array.from({ length: size }, (_, i) => i);
      }
      
      find(x: number): number {
        if (this.parent[x] !== x) {
          this.parent[x] = this.find(this.parent[x]); // 路径压缩
        }
        return this.parent[x];
      }
      
      union(x: number, y: number): boolean {
        const rootX = this.find(x);
        const rootY = this.find(y);
        
        if (rootX !== rootY) {
          this.parent[rootX] = rootY;
          return true;
        }
        return false;
      }
    }

    const n = this.getNodeCount();
    if (n === 0) return { edges: [], cost: 0 };

    // 创建边列表
    const edgeList: { from: number, to: number, weight: number }[] = [];
    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        const weight = this.getEdge(i, j);
        if (weight !== Infinity) {
          edgeList.push({ from: i, to: j, weight });
        }
      }
    }

    // 按权重排序
    edgeList.sort((a, b) => a.weight - b.weight);

    const uf = new UnionFind(n);
    const edges: { from: number, to: number, weight: number }[] = [];
    let totalCost = 0;

    // 选择边
    for (const edge of edgeList) {
      if (uf.union(edge.from, edge.to)) {
        edges.push(edge);
        totalCost += edge.weight;
        if (edges.length === n - 1) break;
      }
    }

    return { edges, cost: totalCost };
  }
}