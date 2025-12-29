import router from '@ohos.router';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { ChinaMapData, CityNode, MapStyle, TransportType } from '../model/MapData';
import { GraphEdge } from '../model/GraphPlus';

interface RouteParams {
  transportType: TransportType;
  mstEdges: GraphEdge[];
  mstEdgesStr?: string;
  cityNames: string[];
}

@Entry
@Component
struct FullScreenMap {
  @State transportType: TransportType = TransportType.RAILWAY;
  @State mstEdges: GraphEdge[] = [];
  @State cityNames: string[] = [];
  @State cities: CityNode[] = ChinaMapData.CITIES;

  // --- 核心状态变量 ---
  @State mapScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;

  // --- 动画与性能控制 ---
  @State drawnEdgeCount: number = 0;
  @State isReplaying: boolean = false;
  @State isInteracting: boolean = false; // 新增：是否正在交互（性能优化开关）
  private replayTimer: number = -1;

  // --- 辅助显示变量 ---
  @State showLabels: boolean = true;
  @State showWeights: boolean = true;
  @State selectedCity: CityNode | null = null;

  // --- 手势计算临时变量 ---
  private lastScale: number = 1;
  private lastOffsetX: number = 0;
  private lastOffsetY: number = 0;

  // --- 画布设置 ---
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params) {
      this.transportType = params.transportType || TransportType.RAILWAY;
      this.cityNames = params.cityNames || ChinaMapData.getCityNames();

      if (params.mstEdgesStr) {
        try {
          this.mstEdges = JSON.parse(params.mstEdgesStr);
        } catch (e) {
          this.mstEdges = [];
        }
      } else {
        this.mstEdges = params.mstEdges || [];
      }
      this.drawnEdgeCount = this.mstEdges.length;
    }
    this.setFullScreen(true);
  }

  aboutToDisappear() {
    this.setFullScreen(false);
    if (this.replayTimer !== -1) {
      clearInterval(this.replayTimer);
    }
  }

  private replayAnimation() {
    if (this.isReplaying) return;

    this.isReplaying = true;
    this.drawnEdgeCount = 0;
    this.redraw();

    this.replayTimer = setInterval(() => {
      if (this.drawnEdgeCount >= this.mstEdges.length) {
        clearInterval(this.replayTimer);
        this.replayTimer = -1;
        this.isReplaying = false;
        return;
      }
      this.drawnEdgeCount++;
      this.redraw();
    }, 300);
  }

  private setFullScreen(isFull: boolean) {
    let context = getContext(this) as common.UIAbilityContext;
    window.getLastWindow(context).then((win) => {
      win.setWindowLayoutFullScreen(isFull);
      if (isFull) {
        win.setWindowSystemBarEnable([]);
      } else {
        win.setWindowSystemBarEnable(['status', 'navigation']);
      }
    });
  }

  private toCanvasX(x: number): number {
    const baseX = (x / 100) * this.canvasWidth * 0.85 + this.canvasWidth * 0.075;
    return baseX * this.mapScale + this.offsetX;
  }

  private toCanvasY(y: number): number {
    const baseY = (y / 100) * this.canvasHeight * 0.85 + this.canvasHeight * 0.075;
    return baseY * this.mapScale + this.offsetY;
  }

  private redraw() {
    if (!this.context || this.canvasWidth === 0) return;
    const ctx = this.context;

    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 1. 背景
    ctx.fillStyle = '#F8F9FA';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 2. 网格 (性能优化：交互时不绘制网格)
    if (!this.isInteracting) {
      this.drawGrid(ctx);
    }

    // 3. 所有底线
    this.drawAllEdges(ctx);

    // 4. MST边
    this.drawMSTEdges(ctx);

    // 5. 城市
    this.drawCities(ctx);

    // 6. 信息框
    if (this.selectedCity) {
      this.drawCityInfo(ctx);
    }
  }

  private drawGrid(ctx: CanvasRenderingContext2D) {
    ctx.strokeStyle = '#E8E8E8';
    ctx.lineWidth = 1;
    const gridSize = 50 * this.mapScale;
    const startX = this.offsetX % gridSize;
    const startY = this.offsetY % gridSize;
    for (let x = startX; x < this.canvasWidth; x += gridSize) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, this.canvasHeight);
      ctx.stroke();
    }
    for (let y = startY; y < this.canvasHeight; y += gridSize) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(this.canvasWidth, y);
      ctx.stroke();
    }
  }

  private drawAllEdges(ctx: CanvasRenderingContext2D) {
    const edges = ChinaMapData.EDGES;
    const color = this.transportType === TransportType.HIGHWAY
      ? MapStyle.COLORS.highwayNormal
      : MapStyle.COLORS.railwayNormal;

    ctx.strokeStyle = color;
    ctx.lineWidth = 2 * this.mapScale;
    ctx.globalAlpha = 0.4;

    if (this.transportType === TransportType.RAILWAY) {
      ctx.setLineDash([8 * this.mapScale, 4 * this.mapScale]);
    }

    // 交互时只画简单的线，不抗锯齿或简化路径（Canvas API 自动处理）
    // 这里保持原逻辑，因为直线绘制很快
    for (const edge of edges) {
      const fromCity = this.cities[edge.from];
      const toCity = this.cities[edge.to];
      ctx.beginPath();
      ctx.moveTo(this.toCanvasX(fromCity.x), this.toCanvasY(fromCity.y));
      ctx.lineTo(this.toCanvasX(toCity.x), this.toCanvasY(toCity.y));
      ctx.stroke();
    }

    ctx.globalAlpha = 1;
    ctx.setLineDash([]);
  }

  private drawMSTEdges(ctx: CanvasRenderingContext2D) {
    const color = this.transportType === TransportType.HIGHWAY
      ? MapStyle.COLORS.highwayMST
      : MapStyle.COLORS.railwayMST;

    ctx.strokeStyle = color;
    ctx.lineWidth = 4 * this.mapScale;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    const limit = Math.min(this.drawnEdgeCount, this.mstEdges.length);

    for (let i = 0; i < limit; i++) {
      const edge = this.mstEdges[i];
      const fromCity = this.cities[edge.from];
      const toCity = this.cities[edge.to];

      // 性能优化：交互时关闭阴影
      if (!this.isInteracting) {
        ctx.shadowColor = color;
        ctx.shadowBlur = 8 * this.mapScale;
      } else {
        ctx.shadowBlur = 0;
      }

      ctx.beginPath();
      ctx.moveTo(this.toCanvasX(fromCity.x), this.toCanvasY(fromCity.y));
      ctx.lineTo(this.toCanvasX(toCity.x), this.toCanvasY(toCity.y));
      ctx.stroke();

      ctx.shadowBlur = 0;

      // 性能优化：交互时不绘制权重文字
      if (this.showWeights && !this.isInteracting) {
        const midX = (this.toCanvasX(fromCity.x) + this.toCanvasX(toCity.x)) / 2;
        const midY = (this.toCanvasY(fromCity.y) + this.toCanvasY(toCity.y)) / 2;
        const fontSize = 12 * this.mapScale;

        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        if (ctx.roundRect) {
          ctx.roundRect(midX - 20 * this.mapScale, midY - 10 * this.mapScale,
            40 * this.mapScale, 20 * this.mapScale, 4 * this.mapScale);
        } else {
          ctx.rect(midX - 20 * this.mapScale, midY - 10 * this.mapScale,
            40 * this.mapScale, 20 * this.mapScale);
        }
        ctx.fill();
        ctx.strokeStyle = color;
        ctx.lineWidth = 1;
        ctx.stroke();

        ctx.fillStyle = color;
        ctx.font = `bold ${fontSize}px sans-serif`;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(edge.weight.toString(), midX, midY);
      }
    }
  }

  private drawCities(ctx: CanvasRenderingContext2D) {
    const mstCitySet = new Set<number>();
    for (const edge of this.mstEdges) {
      mstCitySet.add(edge.from);
      mstCitySet.add(edge.to);
    }

    for (const city of this.cities) {
      const x = this.toCanvasX(city.x);
      const y = this.toCanvasY(city.y);
      const baseRadius = city.isCapital ? 14 : 10;
      const radius = baseRadius * this.mapScale;

      let color = city.isCapital ? MapStyle.COLORS.cityCapital : MapStyle.COLORS.cityNormal;
      if (mstCitySet.has(city.id)) {
        color = MapStyle.COLORS.cityVisited;
      }

      if (this.selectedCity?.id === city.id) {
        ctx.beginPath();
        ctx.arc(x, y, radius + 6 * this.mapScale, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(33, 150, 243, 0.3)';
        ctx.fill();
      }

      ctx.beginPath();
      ctx.arc(x, y, radius, 0, Math.PI * 2);
      ctx.fillStyle = color;
      ctx.fill();
      ctx.strokeStyle = '#FFFFFF';
      ctx.lineWidth = 3 * this.mapScale;
      ctx.stroke();

      // 性能优化：交互时不绘制城市名称
      if (this.showLabels && !this.isInteracting) {
        const fontSize = 14 * this.mapScale;
        ctx.fillStyle = '#333333';
        ctx.font = `bold ${fontSize}px sans-serif`;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';

        const textMetrics = ctx.measureText(city.name);
        const textWidth = textMetrics.width;

        ctx.fillStyle = 'rgba(255,255,255,0.85)';
        ctx.fillRect(x - textWidth/2 - 4, y + radius + 4, textWidth + 8, fontSize + 4);

        ctx.fillStyle = '#333333';
        ctx.fillText(city.name, x, y + radius + 6);
      }
    }
  }

  private drawCityInfo(ctx: CanvasRenderingContext2D) {
    if (!this.selectedCity) return;
    const infoWidth = 200;
    const infoHeight = 100;
    const infoX = 20;
    const infoY = this.canvasHeight - infoHeight - 80;

    ctx.fillStyle = 'rgba(255,255,255,0.95)';
    ctx.beginPath();
    if (ctx.roundRect) {
      ctx.roundRect(infoX, infoY, infoWidth, infoHeight, 10);
    } else {
      ctx.rect(infoX, infoY, infoWidth, infoHeight);
    }

    ctx.fill();
    ctx.strokeStyle = '#2196F3';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.fillStyle = '#333333';
    ctx.font = 'bold 16px sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    ctx.fillText(this.selectedCity.name, infoX + 15, infoY + 15);

    ctx.font = '14px sans-serif';
    ctx.fillStyle = '#666666';
    ctx.fillText(`省份: ${this.selectedCity.province}`, infoX + 15, infoY + 40);

    let connections = 0;
    for (const edge of this.mstEdges) {
      if (edge.from === this.selectedCity.id || edge.to === this.selectedCity.id) {
        connections++;
      }
    }
    ctx.fillText(`MST连接数: ${connections}`, infoX + 15, infoY + 60);
  }

  private handleTap(event: ClickEvent) {
    const tapX = event.x;
    const tapY = event.y;
    for (const city of this.cities) {
      const cityX = this.toCanvasX(city.x);
      const cityY = this.toCanvasY(city.y);
      const radius = (city.isCapital ? 14 : 10) * this.mapScale + 10;
      const distance = Math.sqrt(Math.pow(tapX - cityX, 2) + Math.pow(tapY - cityY, 2));
      if (distance <= radius) {
        this.selectedCity = city;
        this.redraw();
        return;
      }
    }
    this.selectedCity = null;
    this.redraw();
  }

  build() {
    Stack() {
      // 1. 底层：画布 + 手势
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.redraw();
        })
        .onAreaChange((oldArea, newArea) => {
          this.canvasWidth = newArea.width as number;
          this.canvasHeight = newArea.height as number;
          this.redraw();
        })
        .onClick((event: ClickEvent) => {
          this.handleTap(event);
        })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            PinchGesture({ fingers: 2 })
              .onActionStart(() => {
                this.isInteracting = true; // 开始交互
                this.lastScale = this.mapScale;
              })
              .onActionUpdate((event: GestureEvent) => {
                let newScale = this.lastScale * event.scale;
                this.mapScale = Math.max(0.5, Math.min(3.0, newScale));
                this.redraw();
              })
              .onActionEnd(() => {
                this.isInteracting = false; // 结束交互
                this.redraw();
              }),
            PanGesture({ fingers: 1 })
              .onActionStart(() => {
                this.isInteracting = true; // 开始交互
                this.lastOffsetX = this.offsetX;
                this.lastOffsetY = this.offsetY;
              })
              .onActionUpdate((event: GestureEvent) => {
                this.offsetX = this.lastOffsetX + event.offsetX;
                this.offsetY = this.lastOffsetY + event.offsetY;
                this.redraw();
              })
              .onActionEnd(() => {
                this.isInteracting = false; // 结束交互
                this.redraw();
              })
          )
        )

      // 2. 顶部工具栏
      Column() {
        Row() {
          Button('返回')
            .type(ButtonType.Normal)
            .height(36)
            .backgroundColor('rgba(0,0,0,0.5)')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .onClick(() => {
              router.back();
            })

          Blank()

          Button(this.isReplaying ? '播放中...' : '▶ 回放')
            .type(ButtonType.Normal)
            .height(36)
            .backgroundColor(this.isReplaying ? '#FF9800' : '#4CAF50')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .enabled(!this.isReplaying)
            .onClick(() => {
              this.replayAnimation();
            })

          Blank()

          Button('重置')
            .type(ButtonType.Normal)
            .height(36)
            .backgroundColor('rgba(0,0,0,0.5)')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .onClick(() => {
              this.mapScale = 1;
              this.offsetX = 0;
              this.offsetY = 0;
              this.selectedCity = null;
              this.drawnEdgeCount = this.mstEdges.length;
              this.redraw();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
      }
      .width('100%')
      .position({ x: 0, y: 0 })

      // 3. 底部信息栏
      Row({ space: 16 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.showLabels })
          .onChange((isOn: boolean) => {
            this.showLabels = isOn;
            this.redraw();
          })
        Text('城市名').fontSize(14).fontColor('#FFFFFF')

        Toggle({ type: ToggleType.Switch, isOn: this.showWeights })
          .onChange((isOn: boolean) => {
            this.showWeights = isOn;
            this.redraw();
          })
        Text('权重').fontSize(14).fontColor('#FFFFFF')

        Blank()

        Column({ space: 4 }) {
          Text(`边数: ${this.drawnEdgeCount}/${this.mstEdges.length}`).fontSize(12).fontColor('#FFFFFF')
          Text(`权重: ${this.mstEdges.slice(0, this.drawnEdgeCount).reduce((sum, e) => sum + e.weight, 0)}`)
            .fontSize(12).fontColor('#FFFFFF')
        }
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor('rgba(0,0,0,0.6)')
      .position({ x: 0, y: '100%' })
      .translate({ y: -60 })

      // 4. 右侧缩放按钮
      Column({ space: 12 }) {
        Button('+')
          .type(ButtonType.Circle)
          .width(48)
          .height(48)
          .fontSize(24)
          .backgroundColor('rgba(255,255,255,0.9)')
          .fontColor('#333333')
          .onClick(() => {
            this.mapScale = Math.min(3, this.mapScale * 1.2);
            this.redraw();
          })

        Text(`${Math.round(this.mapScale * 100)}%`)
          .fontSize(12)
          .fontColor('#333')
          .backgroundColor('rgba(255,255,255,0.9)')
          .padding(6)
          .borderRadius(4)

        Button('-')
          .type(ButtonType.Circle)
          .width(48)
          .height(48)
          .fontSize(24)
          .backgroundColor('rgba(255,255,255,0.9)')
          .fontColor('#333333')
          .onClick(() => {
            this.mapScale = Math.max(0.5, this.mapScale / 1.2);
            this.redraw();
          })
      }
      .position({ x: '100%', y: '50%' })
      .translate({ x: -70, y: -80 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A2E')
  }
}