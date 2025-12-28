/**
 * 城市数据模型及地理距离计算
 */

export interface City {
  name: string;
  latitude: number;  // 纬度
  longitude: number; // 经度
}

export class CityData {
  // 中国主要城市数据（至少30个城市）
  static readonly CITIES: City[] = [
    { name: "北京", latitude: 39.9042, longitude: 116.4074 },
    { name: "上海", latitude: 31.2304, longitude: 121.4737 },
    { name: "广州", latitude: 23.1291, longitude: 113.2644 },
    { name: "深圳", latitude: 22.5431, longitude: 114.0579 },
    { name: "成都", latitude: 30.5728, longitude: 104.0668 },
    { name: "杭州", latitude: 30.2741, longitude: 120.1551 },
    { name: "武汉", latitude: 30.5928, longitude: 114.3055 },
    { name: "西安", latitude: 34.3416, longitude: 108.9398 },
    { name: "重庆", latitude: 29.5630, longitude: 106.5516 },
    { name: "南京", latitude: 32.0603, longitude: 118.7969 },
    { name: "天津", latitude: 39.3434, longitude: 117.3611 },
    { name: "苏州", latitude: 31.2989, longitude: 120.5853 },
    { name: "青岛", latitude: 36.0631, longitude: 120.3829 },
    { name: "厦门", latitude: 24.4797, longitude: 118.0894 },
    { name: "长沙", latitude: 28.1983, longitude: 112.9801 },
    { name: "郑州", latitude: 34.7474, longitude: 113.6249 },
    { name: "合肥", latitude: 31.8206, longitude: 117.2272 },
    { name: "福州", latitude: 26.0753, longitude: 119.3062 },
    { name: "昆明", latitude: 25.0385, longitude: 102.7188 },
    { name: "沈阳", latitude: 41.7969, longitude: 123.4304 },
    { name: "哈尔滨", latitude: 45.7579, longitude: 126.6467 },
    { name: "兰州", latitude: 36.0611, longitude: 103.8343 },
    { name: "银川", latitude: 38.4667, longitude: 106.2762 },
    { name: "乌鲁木齐", latitude: 43.7928, longitude: 87.6177 },
    { name: "南宁", latitude: 22.8240, longitude: 108.3661 },
    { name: "海口", latitude: 20.0173, longitude: 110.3492 },
    { name: "拉萨", latitude: 29.6456, longitude: 91.1468 },
    { name: "香港", latitude: 22.3964, longitude: 114.1095 },
    { name: "澳门", latitude: 22.1987, longitude: 113.5439 },
    { name: "台北", latitude: 25.0330, longitude: 121.5654 }
  ];

  /**
   * 使用Haversine公式计算两个城市之间的球面距离
   * @param city1 城市1
   * @param city2 城市2
   * @returns 距离（公里），保留1位小数
   */
  static haversineDistance(city1: City, city2: City): number {
    const R = 6371; // 地球半径（公里）
    
    const toRadians = (degrees: number): number => degrees * (Math.PI / 180);
    
    const lat1 = toRadians(city1.latitude);
    const lon1 = toRadians(city1.longitude);
    const lat2 = toRadians(city2.latitude);
    const lon2 = toRadians(city2.longitude);
    
    const dLat = lat2 - lat1;
    const dLon = lon2 - lon1;
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1) * Math.cos(lat2) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
              
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    const distance = R * c;
    
    // 保留1位小数
    return Math.round(distance * 10) / 10;
  }

  /**
   * 根据城市名称查找城市信息
   * @param name 城市名称
   * @returns 城市对象，如果未找到则返回undefined
   */
  static findCityByName(name: string): City | undefined {
    return this.CITIES.find(city => city.name === name);
  }

  /**
   * 获取所有城市名称
   * @returns 城市名称数组
   */
  static getAllCityNames(): string[] {
    return this.CITIES.map(city => city.name);
  }
}