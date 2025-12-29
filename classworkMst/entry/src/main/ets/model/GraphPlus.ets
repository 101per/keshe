/**
 * 增强版图数据结构 - 支持动画步骤记录
 * 完全适配 ArkTS 严格模式
 */

/**
 * 边数据类
 */
export class GraphEdge {
  from: number = 0;
  to: number = 0;
  weight: number = 0;

  constructor(from: number, to: number, weight: number) {
    this.from = from;
    this.to = to;
    this.weight = weight;
  }
}

/**
 * 动画步骤类
 */
export class AnimationStep {
  type: string = ''; // 'check' | 'select' | 'reject' | 'complete'
  edge: GraphEdge = new GraphEdge(-1, -1, 0);
  visited: boolean[] | null = null;
  message: string = '';
  timestamp: number = 0;

  constructor(type: string, edge: GraphEdge, message: string, timestamp: number, visited: boolean[] | null = null) {
    this.type = type;
    this.edge = edge;
    this.message = message;
    this.timestamp = timestamp;
    this.visited = visited;
  }
}

/**
 * MST 结果类
 */
export class MSTResult {
  edges: GraphEdge[] = [];
  cost: number = 0;
  steps: AnimationStep[] = [];

  constructor(edges: GraphEdge[], cost: number, steps: AnimationStep[]) {
    this.edges = edges;
    this.cost = cost;
    this.steps = steps;
  }
}

/**
 * 并查集类 (移至顶层，修复 standalone-this 错误)
 */
class UnionFind {
  private parent: number[] = [];
  private rank: number[] = [];

  constructor(size: number) {
    // 修复泛型推断问题，使用循环初始化
    for (let i = 0; i < size; i++) {
      this.parent.push(i);
      this.rank.push(0);
    }
  }

  find(x: number): number {
    if (this.parent[x] !== x) {
      this.parent[x] = this.find(this.parent[x]);
    }
    return this.parent[x];
  }

  union(x: number, y: number): boolean {
    const rootX = this.find(x);
    const rootY = this.find(y);

    if (rootX !== rootY) {
      if (this.rank[rootX] < this.rank[rootY]) {
        this.parent[rootX] = rootY;
      } else if (this.rank[rootX] > this.rank[rootY]) {
        this.parent[rootY] = rootX;
      } else {
        this.parent[rootY] = rootX;
        this.rank[rootX]++;
      }
      return true;
    }
    return false;
  }
}

export class Graph {
  private cityNames: string[] = [];
  private adjacencyMatrix: number[][] = [];

  constructor(cityNames?: string[], matrix?: number[][]) {
    if (cityNames && matrix) {
      this.initialize(cityNames, matrix);
    }
  }

  initialize(cityNames: string[], matrix: number[][]): void {
    if (cityNames.length !== matrix.length) {
      throw new Error("Invalid matrix dimensions");
    }
    // 检查行长度
    for (let i = 0; i < matrix.length; i++) {
      if (matrix[i].length !== matrix.length) {
        throw new Error("Invalid matrix dimensions");
      }
    }

    // 显式复制数组，避免 map 和 spread operator 的潜在类型问题
    this.cityNames = [];
    for (let i = 0; i < cityNames.length; i++) {
      this.cityNames.push(cityNames[i]);
    }

    this.adjacencyMatrix = [];
    for (let i = 0; i < matrix.length; i++) {
      let row: number[] = [];
      for (let j = 0; j < matrix[i].length; j++) {
        row.push(matrix[i][j]);
      }
      this.adjacencyMatrix.push(row);
    }
  }

  getCityNames(): string[] {
    let result: string[] = [];
    for (let name of this.cityNames) {
      result.push(name);
    }
    return result;
  }

  getAdjacencyMatrix(): number[][] {
    let result: number[][] = [];
    for (let i = 0; i < this.adjacencyMatrix.length; i++) {
      let row: number[] = [];
      for (let j = 0; j < this.adjacencyMatrix[i].length; j++) {
        row.push(this.adjacencyMatrix[i][j]);
      }
      result.push(row);
    }
    return result;
  }

  setEdge(i: number, j: number, value: number): void {
    if (i >= 0 && i < this.adjacencyMatrix.length && j >= 0 && j < this.adjacencyMatrix.length) {
      this.adjacencyMatrix[i][j] = value;
      this.adjacencyMatrix[j][i] = value;
    }
  }

  getEdge(i: number, j: number): number {
    if (i >= 0 && i < this.adjacencyMatrix.length && j >= 0 && j < this.adjacencyMatrix.length) {
      return this.adjacencyMatrix[i][j];
    }
    return Infinity;
  }

  getNodeCount(): number {
    return this.cityNames.length;
  }

  // 辅助方法：复制 boolean 数组
  private copyVisited(visited: boolean[]): boolean[] {
    let copy: boolean[] = [];
    for (let v of visited) {
      copy.push(v);
    }
    return copy;
  }

  /**
   * Prim算法 - 带动画步骤
   */
  primWithAnimation(start: number = 0): MSTResult {
    const n = this.getNodeCount();
    if (n === 0) return new MSTResult([], 0, []);

    // 显式初始化 boolean 数组
    const visited: boolean[] = [];
    for (let i = 0; i < n; i++) {
      visited.push(false);
    }

    const edges: GraphEdge[] = [];
    const steps: AnimationStep[] = [];
    let totalCost = 0;
    let stepTime = 0;

    visited[start] = true;

    // 记录初始步骤
    steps.push(new AnimationStep(
      'select',
      new GraphEdge(start, start, 0),
      `从城市 ${this.cityNames[start]} 开始`,
      stepTime++,
      this.copyVisited(visited)
    ));

    for (let i = 0; i < n - 1; i++) {
      let minWeight = Infinity;
      let nextNode = -1;
      let sourceNode = -1;

      // 检查所有候选边
      for (let u = 0; u < n; u++) {
        if (visited[u]) {
          for (let v = 0; v < n; v++) {
            const weight = this.getEdge(u, v);
            if (!visited[v] && weight !== Infinity) {

              steps.push(new AnimationStep(
                'check',
                new GraphEdge(u, v, weight),
                `检查边 ${this.cityNames[u]} → ${this.cityNames[v]}，权重: ${weight}`,
                stepTime++,
                this.copyVisited(visited)
              ));

              if (weight < minWeight) {
                minWeight = weight;
                nextNode = v;
                sourceNode = u;
              }
            }
          }
        }
      }

      if (nextNode !== -1) {
        visited[nextNode] = true;
        edges.push(new GraphEdge(sourceNode, nextNode, minWeight));
        totalCost += minWeight;

        steps.push(new AnimationStep(
          'select',
          new GraphEdge(sourceNode, nextNode, minWeight),
          `选择边 ${this.cityNames[sourceNode]} → ${this.cityNames[nextNode]}，权重: ${minWeight}`,
          stepTime++,
          this.copyVisited(visited)
        ));
      }
    }

    steps.push(new AnimationStep(
      'complete',
      new GraphEdge(-1, -1, totalCost),
      `最小生成树完成！总权重: ${totalCost}`,
      stepTime++,
      this.copyVisited(visited)
    ));

    return new MSTResult(edges, totalCost, steps);
  }

  /**
   * Kruskal算法 - 带动画步骤
   */
  kruskalWithAnimation(): MSTResult {
    const n = this.getNodeCount();
    if (n === 0) return new MSTResult([], 0, []);

    const steps: AnimationStep[] = [];
    let stepTime = 0;

    // 创建边列表
    const edgeList: GraphEdge[] = [];
    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        const weight = this.getEdge(i, j);
        if (weight !== Infinity) {
          edgeList.push(new GraphEdge(i, j, weight));
        }
      }
    }

    // 排序
    edgeList.sort((a: GraphEdge, b: GraphEdge) => a.weight - b.weight);

    steps.push(new AnimationStep(
      'check',
      new GraphEdge(-1, -1, 0),
      `共有 ${edgeList.length} 条边，按权重排序后开始选择`,
      stepTime++
    ));

    const uf = new UnionFind(n);
    const edges: GraphEdge[] = [];
    let totalCost = 0;

    for (const edge of edgeList) {
      steps.push(new AnimationStep(
        'check',
        edge,
        `检查边 ${this.cityNames[edge.from]} → ${this.cityNames[edge.to]}，权重: ${edge.weight}`,
        stepTime++
      ));

      if (uf.union(edge.from, edge.to)) {
        edges.push(edge);
        totalCost += edge.weight;

        steps.push(new AnimationStep(
          'select',
          edge,
          `✓ 选择边 ${this.cityNames[edge.from]} → ${this.cityNames[edge.to]}，不会形成环`,
          stepTime++
        ));

        if (edges.length === n - 1) break;
      } else {
        steps.push(new AnimationStep(
          'reject',
          edge,
          `✗ 拒绝边 ${this.cityNames[edge.from]} → ${this.cityNames[edge.to]}，会形成环`,
          stepTime++
        ));
      }
    }

    steps.push(new AnimationStep(
      'complete',
      new GraphEdge(-1, -1, totalCost),
      `最小生成树完成！共 ${edges.length} 条边，总权重: ${totalCost}`,
      stepTime++
    ));

    return new MSTResult(edges, totalCost, steps);
  }
}