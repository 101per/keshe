// entry/src/main/ets/utils/Projection.ts

// 1. 定义一个具体的类来表示屏幕坐标点
// 修复 "Object literals cannot be used as type declarations"
export class ScreenPoint {
  x: number = 0;
  y: number = 0;
}

export class Projection {
  // Web Mercator 投影常数
  static readonly TILE_SIZE = 256;

  /**
   * 将经纬度转换为屏幕像素坐标 (相对于地图中心点)
   */
  static convertLatLngToPixel(
    lat: number,
    lng: number,
    centerLat: number,
    centerLng: number,
    zoom: number,
    canvasWidth: number,
    canvasHeight: number
  ): ScreenPoint { // 修复：返回类型改为具体的类 ScreenPoint

    // 1. 计算世界坐标 (World Coordinate)
    // 缩放因子：2^zoom
    const scale = Math.pow(2, zoom);

    // 修复：静态方法内必须用类名 Projection 访问静态常量，不能用 this
    const targetX = (lng + 180) / 360 * Projection.TILE_SIZE * scale;

    // 纬度投影 (Mercator)
    const siny = Math.sin(lat * Math.PI / 180);
    // 截断两极，防止无穷大
    const sinyClamped = Math.min(Math.max(siny, -0.9999), 0.9999);

    // 修复：使用 Projection.TILE_SIZE
    const targetY = (0.5 - Math.log((1 + sinyClamped) / (1 - sinyClamped)) / (4 * Math.PI)) * Projection.TILE_SIZE * scale;

    // 2. 计算中心点的绝对像素位置
    // 修复：使用 Projection.TILE_SIZE
    const centerX = (centerLng + 180) / 360 * Projection.TILE_SIZE * scale;
    const sinyCenter = Math.sin(centerLat * Math.PI / 180);
    const sinyCenterClamped = Math.min(Math.max(sinyCenter, -0.9999), 0.9999);

    // 修复：使用 Projection.TILE_SIZE
    const centerY = (0.5 - Math.log((1 + sinyCenterClamped) / (1 - sinyCenterClamped)) / (4 * Math.PI)) * Projection.TILE_SIZE * scale;

    // 3. 计算相对偏移量
    // 屏幕中心就是 (canvasWidth/2, canvasHeight/2)
    // 目标点坐标 = 屏幕中心 + (目标绝对 - 中心绝对)
    const x = canvasWidth / 2 + (targetX - centerX);
    const y = canvasHeight / 2 + (targetY - centerY);

    // 修复：返回具体的对象实例，符合 ArkTS 严格模式
    let point = new ScreenPoint();
    point.x = x;
    point.y = y;
    return point;
  }
}


