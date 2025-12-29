/**
 * 静态地图数据 - 离线可用
 * 包含城市坐标和预定义的道路/铁路网络
 */

// 城市节点定义
export interface CityNode {
  id: number;
  name: string;
  x: number;      // 相对坐标 0-100
  y: number;      // 相对坐标 0-100
  isCapital?: boolean;
  province?: string;
}

// 边定义
export interface EdgeData {
  from: number;
  to: number;
  highwayDistance: number;    // 高速公路距离(km)
  railwayDistance: number;    // 铁路距离(km)
  highwayTime: number;        // 驾车时间(分钟)
  railwayTime: number;        // 火车时间(分钟)
}

// 交通类型
export enum TransportType {
  HIGHWAY = 'highway',
  RAILWAY = 'railway'
}

/**
 * 中国主要城市地图数据（简化版）
 */
export class ChinaMapData {
  // 城市节点数据
  static readonly CITIES: CityNode[] = [
    { id: 0, name: '北京', x: 60, y: 22, isCapital: true, province: '北京' },
    { id: 1, name: '天津', x: 63, y: 25, province: '天津' },
    { id: 2, name: '石家庄', x: 57, y: 28, province: '河北' },
    { id: 3, name: '太原', x: 52, y: 28, province: '山西' },
    { id: 4, name: '济南', x: 60, y: 33, province: '山东' },
    { id: 5, name: '郑州', x: 55, y: 38, province: '河南' },
    { id: 6, name: '武汉', x: 55, y: 48, province: '湖北' },
    { id: 7, name: '长沙', x: 54, y: 56, province: '湖南' },
    { id: 8, name: '广州', x: 54, y: 72, province: '广东' },
    { id: 9, name: '深圳', x: 56, y: 75, province: '广东' },
    { id: 10, name: '上海', x: 72, y: 42, province: '上海' },
    { id: 11, name: '南京', x: 66, y: 40, province: '江苏' },
    { id: 12, name: '杭州', x: 70, y: 48, province: '浙江' },
    { id: 13, name: '合肥', x: 62, y: 42, province: '安徽' },
    { id: 14, name: '南昌', x: 60, y: 54, province: '江西' },
    { id: 15, name: '西安', x: 45, y: 38, province: '陕西' },
    { id: 16, name: '成都', x: 35, y: 48, province: '四川' },
    { id: 17, name: '重庆', x: 40, y: 52, province: '重庆' },
    { id: 18, name: '昆明', x: 32, y: 68, province: '云南' },
    { id: 19, name: '贵阳', x: 40, y: 62, province: '贵州' },
    { id: 20, name: '兰州', x: 35, y: 32, province: '甘肃' },
    { id: 21, name: '西宁', x: 28, y: 30, province: '青海' },
    { id: 22, name: '沈阳', x: 70, y: 15, province: '辽宁' },
    { id: 23, name: '哈尔滨', x: 75, y: 8, province: '黑龙江' },
    { id: 24, name: '长春', x: 73, y: 12, province: '吉林' }
  ];

  // 边数据 - 高速公路和铁路
  static readonly EDGES: EdgeData[] = [
    // 京津冀区域
    { from: 0, to: 1, highwayDistance: 137, railwayDistance: 120, highwayTime: 90, railwayTime: 35 },
    { from: 0, to: 2, highwayDistance: 289, railwayDistance: 281, highwayTime: 180, railwayTime: 70 },
    { from: 1, to: 2, highwayDistance: 302, railwayDistance: 295, highwayTime: 190, railwayTime: 75 },
    { from: 2, to: 3, highwayDistance: 238, railwayDistance: 225, highwayTime: 150, railwayTime: 100 },
    { from: 1, to: 4, highwayDistance: 356, railwayDistance: 340, highwayTime: 220, railwayTime: 90 },

    // 京沪线
    { from: 0, to: 4, highwayDistance: 420, railwayDistance: 405, highwayTime: 260, railwayTime: 100 },
    { from: 4, to: 11, highwayDistance: 565, railwayDistance: 550, highwayTime: 340, railwayTime: 130 },
    { from: 11, to: 10, highwayDistance: 302, railwayDistance: 295, highwayTime: 180, railwayTime: 70 },

    // 中部区域
    { from: 4, to: 5, highwayDistance: 330, railwayDistance: 315, highwayTime: 200, railwayTime: 90 },
    { from: 5, to: 6, highwayDistance: 536, railwayDistance: 520, highwayTime: 320, railwayTime: 120 },
    { from: 6, to: 7, highwayDistance: 350, railwayDistance: 340, highwayTime: 210, railwayTime: 80 },
    { from: 7, to: 8, highwayDistance: 680, railwayDistance: 665, highwayTime: 400, railwayTime: 150 },
    { from: 8, to: 9, highwayDistance: 140, railwayDistance: 130, highwayTime: 90, railwayTime: 30 },

    // 长三角区域
    { from: 11, to: 13, highwayDistance: 156, railwayDistance: 150, highwayTime: 100, railwayTime: 50 },
    { from: 11, to: 12, highwayDistance: 275, railwayDistance: 265, highwayTime: 170, railwayTime: 65 },
    { from: 10, to: 12, highwayDistance: 175, railwayDistance: 165, highwayTime: 110, railwayTime: 50 },
    { from: 12, to: 14, highwayDistance: 470, railwayDistance: 455, highwayTime: 280, railwayTime: 180 },
    { from: 6, to: 14, highwayDistance: 360, railwayDistance: 350, highwayTime: 220, railwayTime: 120 },

    // 西部区域
    { from: 3, to: 15, highwayDistance: 508, railwayDistance: 495, highwayTime: 300, railwayTime: 180 },
    { from: 5, to: 15, highwayDistance: 480, railwayDistance: 465, highwayTime: 290, railwayTime: 120 },
    { from: 15, to: 16, highwayDistance: 698, railwayDistance: 680, highwayTime: 420, railwayTime: 240 },
    { from: 15, to: 20, highwayDistance: 676, railwayDistance: 660, highwayTime: 400, railwayTime: 330 },
    { from: 20, to: 21, highwayDistance: 227, railwayDistance: 220, highwayTime: 150, railwayTime: 120 },

    // 西南区域
    { from: 16, to: 17, highwayDistance: 320, railwayDistance: 310, highwayTime: 200, railwayTime: 100 },
    { from: 17, to: 19, highwayDistance: 370, railwayDistance: 360, highwayTime: 230, railwayTime: 130 },
    { from: 19, to: 18, highwayDistance: 540, railwayDistance: 525, highwayTime: 320, railwayTime: 210 },
    { from: 6, to: 17, highwayDistance: 890, railwayDistance: 870, highwayTime: 530, railwayTime: 300 },
    { from: 7, to: 19, highwayDistance: 720, railwayDistance: 700, highwayTime: 430, railwayTime: 270 },
    { from: 8, to: 19, highwayDistance: 850, railwayDistance: 830, highwayTime: 510, railwayTime: 280 },

    // 东北区域
    { from: 0, to: 22, highwayDistance: 685, railwayDistance: 670, highwayTime: 410, railwayTime: 150 },
    { from: 22, to: 24, highwayDistance: 305, railwayDistance: 295, highwayTime: 190, railwayTime: 80 },
    { from: 24, to: 23, highwayDistance: 242, railwayDistance: 235, highwayTime: 150, railwayTime: 70 },

    // 补充连接
    { from: 13, to: 5, highwayDistance: 462, railwayDistance: 450, highwayTime: 280, railwayTime: 150 },
    { from: 13, to: 6, highwayDistance: 375, railwayDistance: 365, highwayTime: 230, railwayTime: 120 },
    { from: 14, to: 8, highwayDistance: 720, railwayDistance: 700, highwayTime: 430, railwayTime: 200 }
  ];

  /**
   * 获取指定交通类型的邻接矩阵
   */
  static getAdjacencyMatrix(type: TransportType, useTime: boolean = false): number[][] {
    const n = ChinaMapData.CITIES.length;
    // 使用明确的循环初始化二维数组，避免 ArkTS 推断错误
    const matrix: number[][] = [];

    for (let i = 0; i < n; i++) {
      let row: number[] = [];
      for (let j = 0; j < n; j++) {
        row.push(Infinity);
      }
      matrix.push(row);
    }

    // 对角线为0
    for (let i = 0; i < n; i++) {
      matrix[i][i] = 0;
    }

    // 填充边权重
    for (const edge of ChinaMapData.EDGES) {
      let weight: number;
      if (type === TransportType.HIGHWAY) {
        weight = useTime ? edge.highwayTime : edge.highwayDistance;
      } else {
        weight = useTime ? edge.railwayTime : edge.railwayDistance;
      }
      matrix[edge.from][edge.to] = weight;
      matrix[edge.to][edge.from] = weight;
    }

    return matrix;
  }

  /**
   * 获取城市名称数组
   */
  static getCityNames(): string[] {
    return ChinaMapData.CITIES.map((city: CityNode) => city.name);
  }
}

/**
 * 为了符合 ArkTS "对象字面量必须对应显式声明的类" 规则，
 * 我们定义 MapColors 和 MapSizes 类
 */
export class MapColors {
  background: string = '#F5F5F5';
  land: string = '#E8E8E8';
  border: string = '#CCCCCC';

  // 城市
  cityNormal: string = '#2196F3';
  cityCapital: string = '#F44336';
  cityVisited: string = '#4CAF50';
  cityText: string = '#333333';

  // 高速公路
  highwayNormal: string = '#90CAF9';
  highwayMST: string = '#1565C0';
  highwayHighlight: string = '#FF9800';

  // 铁路
  railwayNormal: string = '#BCAAA4';
  railwayMST: string = '#5D4037';
  railwayHighlight: string = '#FF5722';

  // 动画
  animationStart: string = '#FFEB3B';
  animationEnd: string = '#4CAF50';
  animationProcessing: string = '#FF9800';
}

export class MapSizes {
  cityRadius: number = 8;
  capitalRadius: number = 12;
  edgeWidth: number = 2;
  mstEdgeWidth: number = 4;
  fontSize: number = 12;
  labelOffset: number = 15;
}

/**
 * 地图视觉样式配置
 */
export class MapStyle {
  static readonly COLORS: MapColors = new MapColors();
  static readonly SIZES: MapSizes = new MapSizes();
}