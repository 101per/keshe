import { ChinaMapData, CityNode, MapStyle, TransportType } from '../model/MapData';
// 引入 GraphEdge 类
import { AnimationStep, GraphEdge } from '../model/GraphPlus';

@Component
export struct MapCanvas {
  @Prop mapWidth: number = 400;
  @Prop mapHeight: number = 500;
  @Prop transportType: TransportType = TransportType.RAILWAY;

  // 修改类型为 GraphEdge[]
  @Prop @Watch('onMSTEdgesChange') mstEdges: GraphEdge[] = [];
  @Prop @Watch('onAnimationStepChange') currentStep: AnimationStep | null = null;
  @Prop showAllEdges: boolean = true;
  @Prop isAnimating: boolean = false;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  @State private cities: CityNode[] = ChinaMapData.CITIES;
  // 显式指定 Set 泛型
  @State private visitedCities: Set<number> = new Set<number>();
  // 修改类型为 GraphEdge
  @State private highlightEdge: GraphEdge | null = null;

  onMSTEdgesChange() {
    this.redraw();
  }

  onAnimationStepChange() {
    if (this.currentStep) {
      if (this.currentStep.visited) {
        // 修复 Set 初始化
        this.visitedCities.clear();
        this.currentStep.visited.forEach((v, i) => {
          if (v) this.visitedCities.add(i);
        });
      }
      if (this.currentStep.type === 'check' || this.currentStep.type === 'select' || this.currentStep.type === 'reject') {
        this.highlightEdge = this.currentStep.edge;
      }
    }
    this.redraw();
  }

  // 坐标转换
  private toCanvasX(x: number): number {
    return (x / 100) * this.mapWidth * 0.9 + this.mapWidth * 0.05;
  }

  private toCanvasY(y: number): number {
    return (y / 100) * this.mapHeight * 0.9 + this.mapHeight * 0.05;
  }

  private redraw() {
    if (!this.context) return;

    const ctx = this.context;

    // 清空画布
    ctx.clearRect(0, 0, this.mapWidth, this.mapHeight);

    // 绘制背景
    this.drawBackground(ctx);

    // 绘制所有边（如果启用）
    if (this.showAllEdges) {
      this.drawAllEdges(ctx);
    }

    // 绘制MST边
    this.drawMSTEdges(ctx);

    // 绘制高亮边（动画中）
    if (this.highlightEdge && this.isAnimating) {
      this.drawHighlightEdge(ctx);
    }

    // 绘制城市节点
    this.drawCities(ctx);

    // 绘制图例
    this.drawLegend(ctx);
  }

  private drawBackground(ctx: CanvasRenderingContext2D) {
    ctx.fillStyle = MapStyle.COLORS.land;
    ctx.strokeStyle = MapStyle.COLORS.border;
    ctx.lineWidth = 2;

    ctx.beginPath();
    // 使用 rect 替代 roundRect 兼容性更好，或者保留 roundRect
    // ctx.rect(10, 10, this.mapWidth - 20, this.mapHeight - 20);
    // 如果 SDK 版本支持 roundRect 则保留，否则用 rect
    if (ctx.roundRect) {
      ctx.roundRect(10, 10, this.mapWidth - 20, this.mapHeight - 20, 10);
    } else {
      ctx.rect(10, 10, this.mapWidth - 20, this.mapHeight - 20);
    }
    ctx.fill();
    ctx.stroke();

    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 0.5;
    const gridSize = 50;
    for (let x = gridSize; x < this.mapWidth; x += gridSize) {
      ctx.beginPath();
      ctx.moveTo(x, 10);
      ctx.lineTo(x, this.mapHeight - 10);
      ctx.stroke();
    }
    for (let y = gridSize; y < this.mapHeight; y += gridSize) {
      ctx.beginPath();
      ctx.moveTo(10, y);
      ctx.lineTo(this.mapWidth - 10, y);
      ctx.stroke();
    }
  }

  private drawAllEdges(ctx: CanvasRenderingContext2D) {
    const edges = ChinaMapData.EDGES;
    const color = this.transportType === TransportType.HIGHWAY
      ? MapStyle.COLORS.highwayNormal
      : MapStyle.COLORS.railwayNormal;

    ctx.strokeStyle = color;
    ctx.lineWidth = MapStyle.SIZES.edgeWidth;
    ctx.setLineDash(this.transportType === TransportType.RAILWAY ? [5, 5] : []);

    for (const edge of edges) {
      const fromCity = this.cities[edge.from];
      const toCity = this.cities[edge.to];

      ctx.beginPath();
      ctx.moveTo(this.toCanvasX(fromCity.x), this.toCanvasY(fromCity.y));
      ctx.lineTo(this.toCanvasX(toCity.x), this.toCanvasY(toCity.y));
      ctx.stroke();
    }

    ctx.setLineDash([]);
  }

  private drawMSTEdges(ctx: CanvasRenderingContext2D) {
    const color = this.transportType === TransportType.HIGHWAY
      ? MapStyle.COLORS.highwayMST
      : MapStyle.COLORS.railwayMST;

    ctx.strokeStyle = color;
    ctx.lineWidth = MapStyle.SIZES.mstEdgeWidth;
    ctx.lineCap = 'round';

    for (const edge of this.mstEdges) {
      if (this.highlightEdge &&
        edge.from === this.highlightEdge.from &&
        edge.to === this.highlightEdge.to) {
        continue;
      }

      const fromCity = this.cities[edge.from];
      const toCity = this.cities[edge.to];

      ctx.beginPath();
      ctx.moveTo(this.toCanvasX(fromCity.x), this.toCanvasY(fromCity.y));
      ctx.lineTo(this.toCanvasX(toCity.x), this.toCanvasY(toCity.y));
      ctx.stroke();

      const midX = (this.toCanvasX(fromCity.x) + this.toCanvasX(toCity.x)) / 2;
      const midY = (this.toCanvasY(fromCity.y) + this.toCanvasY(toCity.y)) / 2;

      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(midX - 15, midY - 8, 30, 16);
      ctx.fillStyle = color;
      ctx.font = '10px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(edge.weight.toString(), midX, midY);
    }
  }

  private drawHighlightEdge(ctx: CanvasRenderingContext2D) {
    if (!this.highlightEdge || this.highlightEdge.from < 0) return;

    const edge = this.highlightEdge;
    const fromCity = this.cities[edge.from];
    const toCity = this.cities[edge.to];

    ctx.shadowColor = MapStyle.COLORS.animationProcessing;
    ctx.shadowBlur = 10;

    ctx.strokeStyle = this.currentStep?.type === 'select'
      ? MapStyle.COLORS.animationEnd
      : this.currentStep?.type === 'reject'
        ? '#F44336'
        : MapStyle.COLORS.animationProcessing;
    ctx.lineWidth = MapStyle.SIZES.mstEdgeWidth + 2;

    ctx.beginPath();
    ctx.moveTo(this.toCanvasX(fromCity.x), this.toCanvasY(fromCity.y));
    ctx.lineTo(this.toCanvasX(toCity.x), this.toCanvasY(toCity.y));
    ctx.stroke();

    ctx.shadowBlur = 0;
  }

  private drawCities(ctx: CanvasRenderingContext2D) {
    for (const city of this.cities) {
      const x = this.toCanvasX(city.x);
      const y = this.toCanvasY(city.y);
      const radius = city.isCapital ? MapStyle.SIZES.capitalRadius : MapStyle.SIZES.cityRadius;

      let color = city.isCapital ? MapStyle.COLORS.cityCapital : MapStyle.COLORS.cityNormal;
      if (this.visitedCities.has(city.id)) {
        color = MapStyle.COLORS.cityVisited;
      }

      ctx.beginPath();
      ctx.arc(x, y, radius, 0, Math.PI * 2);
      ctx.fillStyle = color;
      ctx.fill();
      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 2;
      ctx.stroke();

      ctx.fillStyle = MapStyle.COLORS.cityText;
      ctx.font = `${MapStyle.SIZES.fontSize}px sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'top';
      ctx.fillText(city.name, x, y + radius + 3);
    }
  }

  private drawLegend(ctx: CanvasRenderingContext2D) {
    const legendX = 20;
    const legendY = this.mapHeight - 80;

    ctx.fillStyle = 'rgba(255,255,255,0.9)';
    ctx.fillRect(legendX - 5, legendY - 5, 120, 70);
    ctx.strokeStyle = '#CCCCCC';
    ctx.strokeRect(legendX - 5, legendY - 5, 120, 70);

    ctx.font = '11px sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'middle';

    const typeName = this.transportType === TransportType.HIGHWAY ? '高速公路' : '铁路';
    ctx.fillStyle = '#333333';
    ctx.fillText(`当前: ${typeName}`, legendX, legendY + 5);

    const normalColor = this.transportType === TransportType.HIGHWAY
      ? MapStyle.COLORS.highwayNormal
      : MapStyle.COLORS.railwayNormal;
    ctx.fillStyle = normalColor;
    ctx.fillRect(legendX, legendY + 18, 20, 3);
    ctx.fillStyle = '#333333';
    ctx.fillText('可选路线', legendX + 25, legendY + 20);

    const mstColor = this.transportType === TransportType.HIGHWAY
      ? MapStyle.COLORS.highwayMST
      : MapStyle.COLORS.railwayMST;
    ctx.fillStyle = mstColor;
    ctx.fillRect(legendX, legendY + 33, 20, 4);
    ctx.fillStyle = '#333333';
    ctx.fillText('最优路线', legendX + 25, legendY + 35);

    ctx.beginPath();
    ctx.arc(legendX + 6, legendY + 50, 5, 0, Math.PI * 2);
    ctx.fillStyle = MapStyle.COLORS.cityNormal;
    ctx.fill();
    ctx.fillStyle = '#333333';
    ctx.fillText('城市节点', legendX + 25, legendY + 50);
  }

  build() {
    Canvas(this.context)
      .width(this.mapWidth)
      .height(this.mapHeight)
      .backgroundColor(MapStyle.COLORS.background)
      .onReady(() => {
        this.redraw();
      })
  }
}