/**
 * 通用工具类
 */

export class CommonUtils {
  /**
   * 深拷贝对象
   * @param obj 要拷贝的对象
   * @returns 拷贝后的对象
   */
  static deepClone<T>(obj: T): T {
    if (obj === null || typeof obj !== 'object') {
      return obj;
    }

    if (obj instanceof Date) {
      return new Date(obj.getTime()) as any;
    }

    if (obj instanceof Array) {
      const clonedArray = [] as any[];
      for (let i = 0; i < obj.length; i++) {
        clonedArray[i] = this.deepClone(obj[i]);
      }
      return clonedArray as any;
    }

    if (typeof obj === 'object') {
      const clonedObj = {} as T;
      for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
          clonedObj[key] = this.deepClone(obj[key]);
        }
      }
      return clonedObj;
    }

    return obj;
  }

  /**
   * 生成随机连通图的邻接矩阵
   * @param nodeCount 节点数量
   * @param maxWeight 最大权重值
   * @returns 邻接矩阵
   */
  static generateRandomConnectedGraph(nodeCount: number, maxWeight: number = 100): number[][] {
    // 初始化邻接矩阵，所有值设为无穷大
    const matrix: number[][] = Array(nodeCount)
      .fill(null)
      .map(() => Array(nodeCount).fill(Infinity));

    // 创建一个连通图 - 先创建一个生成树
    const visited: boolean[] = new Array(nodeCount).fill(false);
    visited[0] = true;

    // 使用Prim算法思想创建连通图
    for (let i = 0; i < nodeCount - 1; i++) {
      // 找到已访问节点和未访问节点之间的连接
      const connectedNodes: { from: number, to: number }[] = [];
      
      for (let u = 0; u < nodeCount; u++) {
        if (visited[u]) {
          for (let v = 0; v < nodeCount; v++) {
            if (!visited[v]) {
              connectedNodes.push({ from: u, to: v });
            }
          }
        }
      }

      // 随机选择一个连接
      if (connectedNodes.length > 0) {
        const randomIndex = Math.floor(Math.random() * connectedNodes.length);
        const connection = connectedNodes[randomIndex];
        const weight = Math.floor(Math.random() * maxWeight) + 1;
        
        matrix[connection.from][connection.to] = weight;
        matrix[connection.to][connection.from] = weight;
        visited[connection.to] = true;
      }
    }

    // 添加一些额外的边以使图更加密集
    const extraEdges = Math.floor((nodeCount * (nodeCount - 1)) / 4);
    for (let i = 0; i < extraEdges; i++) {
      const from = Math.floor(Math.random() * nodeCount);
      let to;
      do {
        to = Math.floor(Math.random() * nodeCount);
      } while (to === from);
      
      if (matrix[from][to] === Infinity) {
        const weight = Math.floor(Math.random() * maxWeight) + 1;
        matrix[from][to] = weight;
        matrix[to][from] = weight;
      }
    }

    // 对角线设为0
    for (let i = 0; i < nodeCount; i++) {
      matrix[i][i] = 0;
    }

    return matrix;
  }

  /**
   * 格式化数字显示
   * @param value 数字值
   * @returns 格式化后的字符串
   */
  static formatNumber(value: number): string {
    if (value === Infinity) {
      return "-";
    }
    return value.toString();
  }
}