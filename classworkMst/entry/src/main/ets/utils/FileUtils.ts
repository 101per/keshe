import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import { Graph } from '../model/Graph';

export interface GraphData {
  cityNames: string[];
  matrix: number[][];
}

export class FileUtils {
  /**
   * 保存图数据到文件 - 显式接收 context
   */
  static async saveGraphToFile(context: common.Context, graph: Graph, fileName: string): Promise<boolean> {
    try {
      const finalName = fileName.endsWith('.json') ? fileName : `${fileName}.json`;
      const filePath = `${context.filesDir}/${finalName}`;

      // 显式提取数据，确保不包含循环引用或多余对象属性
      const graphData: GraphData = {
        cityNames: [...graph.getCityNames()],
        matrix: graph.getAdjacencyMatrix().map(row => [...row])
      };

      const jsonString = JSON.stringify(graphData);

      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, jsonString);
      fs.closeSync(file.fd);
      return true;
    } catch (error) {
      console.error('FileUtils Error:', error);
      return false;
    }
  }

  /**
   * 从文件加载图数据
   */
  static async loadGraphFromFile(context: common.Context, fileName: string): Promise<GraphData | null> {
    try {
      const filePath = `${context.filesDir}/${fileName}`;
      if (!fs.accessSync(filePath)) return null;
      const content = fs.readTextSync(filePath);
      return JSON.parse(content) as GraphData;
    } catch (error) {
      console.error('FileUtils: Load failed', JSON.stringify(error));
      return null;
    }
  }

  /**
   * 获取目录下已保存的所有 JSON 文件列表
   */
  static listGraphFiles(context: common.Context): string[] {
    try {
      let files = fs.listFileSync(context.filesDir);
      return files.filter(f => f.endsWith('.json'));
    } catch (e) {
      return [];
    }
  }

  static deleteGraphFile(context: common.Context, fileName: string): boolean {
    try {
      const filePath = `${context.filesDir}/${fileName}`;
      if (fs.accessSync(filePath)) {
        fs.unlinkSync(filePath); // 物理删除文件
        return true;
      }
      return false;
    } catch (error) {
      console.error('FileUtils: Delete failed', JSON.stringify(error));
      return false;
    }
  }
}