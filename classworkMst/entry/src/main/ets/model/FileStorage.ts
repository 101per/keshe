/**
 * 文件存储模块，用于保存和加载图数据
 */

export class FileStorage {
  private static readonly GRAPH_DATA_KEY = 'graph_data';

  /**
   * 保存图数据到本地存储
   * @param cityNames 城市名称数组
   * @param matrix 邻接矩阵
   * @returns Promise<boolean> 保存是否成功
   */
  static async saveGraph(cityNames: string[], matrix: number[][]): Promise<boolean> {
    try {
      const data = {
        cityNames: cityNames,
        matrix: matrix
      };
      
      const jsonData = JSON.stringify(data);
      let localStorage = new LocalStorage();
      await localStorage.set(this.GRAPH_DATA_KEY, jsonData);
      return true;
    } catch (error) {
      console.error('保存图数据失败:', error);
      return false;
    }
  }

  /**
   * 从本地存储加载图数据
   * @returns Promise<{cityNames: string[], matrix: number[][]} | null> 加载的数据或null
   */
  static async loadGraph(): Promise<{cityNames: string[], matrix: number[][]} | null> {
    try {
      let localStorage = new LocalStorage();
      const jsonData = await localStorage.get(this.GRAPH_DATA_KEY);
      if (jsonData && typeof jsonData === 'string') {
        const data = JSON.parse(jsonData);
        return {
          cityNames: data.cityNames || [],
          matrix: data.matrix || []
        };
      }
      return null;
    } catch (error) {
      console.error('加载图数据失败:', error);
      return null;
    }
  }
}