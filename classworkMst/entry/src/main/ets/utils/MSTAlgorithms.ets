import { GraphEdge, NodeInfo, AnimationStep } from '../model/GraphPPlus';

export class MSTAlgorithms {

  // 工具方法：计算距离
  private static getDist(n1: NodeInfo, n2: NodeInfo): number {
    const dx = n1.lng - n2.lng;
    const dy = n1.lat - n2.lat;
    return Math.sqrt(dx * dx + dy * dy);
  }

  // 获取完全图的所有边（Kruskal用）
  static getAllEdges(nodes: NodeInfo[]): GraphEdge[] {
    let edges: GraphEdge[] = [];
    for (let i = 0; i < nodes.length; i++) {
      for (let j = i + 1; j < nodes.length; j++) {
        edges.push({
          from: i,
          to: j,
          // 【修复1】这里不能用 this.getDist，改为 MSTAlgorithms.getDist
          weight: parseFloat(MSTAlgorithms.getDist(nodes[i], nodes[j]).toFixed(4))
        });
      }
    }
    return edges.sort((a, b) => a.weight - b.weight);
  }

  // --- Prim 算法 ---
  static runPrim(nodes: NodeInfo[], startIndex: number): AnimationStep[] {
    const n = nodes.length;
    const steps: AnimationStep[] = [];
    const mstEdges: GraphEdge[] = [];
    let totalCost = 0;

    // 【修复2】显式定义数组类型，解决 "no-any" 报错
    let visited: boolean[] = new Array(n).fill(false);
    let dist: number[] = new Array(n).fill(Number.MAX_VALUE);
    let parent: number[] = new Array(n).fill(-1);

    dist[startIndex] = 0;
    steps.push({ type: 'init', message: `初始化 Prim，起点: ${nodes[startIndex].name}`, edgesSoFar: [], costSoFar: 0 });

    for (let i = 0; i < n; i++) {
      let u = -1;
      let minVal = Number.MAX_VALUE;
      for (let j = 0; j < n; j++) {
        if (!visited[j] && dist[j] < minVal) {
          minVal = dist[j];
          u = j;
        }
      }

      if (u === -1) break;
      visited[u] = true;

      if (u !== startIndex) {
        const edge: GraphEdge = { from: parent[u], to: u, weight: minVal };
        mstEdges.push(edge);
        totalCost += minVal;
        steps.push({
          type: 'select',
          message: `连接: ${nodes[parent[u]].name} -> ${nodes[u].name}`,
          edge: edge,
          edgesSoFar: [...mstEdges], // 浅拷贝数组
          costSoFar: totalCost
        });
      }

      for (let v = 0; v < n; v++) {
        if (!visited[v]) {
          // 【修复1】使用 MSTAlgorithms.getDist
          let weight = MSTAlgorithms.getDist(nodes[u], nodes[v]);
          if (weight < dist[v]) {
            dist[v] = weight;
            parent[v] = u;
          }
        }
      }
    }

    steps.push({ type: 'complete', message: `Prim 完成，总距离: ${totalCost.toFixed(2)}`, edgesSoFar: mstEdges, costSoFar: totalCost });
    return steps;
  }

  // --- Kruskal 算法 ---
  static runKruskal(nodes: NodeInfo[]): AnimationStep[] {
    const steps: AnimationStep[] = [];
    const mstEdges: GraphEdge[] = [];
    let totalCost = 0;

    // 【修复1】使用 MSTAlgorithms.getAllEdges
    let edges = MSTAlgorithms.getAllEdges(nodes);

    // 【修复2】显式定义 parent 数组类型，并给 map 参数增加类型注解
    let parent: number[] = new Array(nodes.length).fill(0).map((_: number, i: number) => i);

    // 并查集查找
    const find = (i: number): number => {
      // 路径压缩
      if (parent[i] === i) {
        return i;
      } else {
        parent[i] = find(parent[i]);
        return parent[i];
      }
    };

    // 并查集和并
    const union = (i: number, j: number): boolean => {
      let rootI = find(i);
      let rootJ = find(j);
      if (rootI !== rootJ) {
        parent[rootI] = rootJ;
        return true;
      }
      return false;
    };

    steps.push({ type: 'init', message: `Kruskal 初始化，按权重排序边`, edgesSoFar: [], costSoFar: 0 });

    for (let edge of edges) {
      if (union(edge.from, edge.to)) {
        mstEdges.push(edge);
        totalCost += edge.weight;
        steps.push({
          type: 'select',
          message: `连接: ${nodes[edge.from].name} - ${nodes[edge.to].name}`,
          edge: edge,
          edgesSoFar: [...mstEdges],
          costSoFar: totalCost
        });
      }
      // 优化：如果边数等于节点数-1，说明树已生成，提前结束
      if (mstEdges.length === nodes.length - 1) break;
    }

    steps.push({ type: 'complete', message: `Kruskal 完成，总距离: ${totalCost.toFixed(2)}`, edgesSoFar: mstEdges, costSoFar: totalCost });
    return steps;
  }
}