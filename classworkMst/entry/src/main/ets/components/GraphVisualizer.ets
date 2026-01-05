// 定义内部接口，确保类型安全
interface Edge {
  from: number;
  to: number;
  weight: number;
}

interface Point {
  x: number;
  y: number;
}

@Component
export struct GraphVisualizer {
  // 必须使用 @Prop 接收外部传入的属性
  @Prop @Watch('onDataChange') cityNames: string[] = [];
  @Prop @Watch('onDataChange') allEdges: Edge[] = [];
  @Prop @Watch('onDataChange') mstEdges: Edge[] = [];
  @Prop @Watch('onDataChange') isAnimating: boolean = false;
  @Prop @Watch('onDataChange') currentStep: number = 0;

  // --- 修正点 1：Canvas 上下文的正确初始化方式 ---
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private isCanvasReady: boolean = false;

  // 监听属性变化
  onDataChange() {
    if (this.isCanvasReady) {
      this.drawGraph();
    }
  }

  private drawGraph(): void {
    const ctx = this.canvasContext;
    if (!ctx || !this.cityNames || this.cityNames.length === 0) return;

    // 获取当前 Canvas 实际宽高
    const w = ctx.width;
    const h = ctx.height;

    // 清除画布
    ctx.clearRect(0, 0, w, h);

    const centerX = w / 2;
    const centerY = h / 2;
    const radius = Math.min(w, h) / 2 - 30;

    // 1. 计算所有节点位置
    const nodePositions: Point[] = this.cityNames.map((_, i) => {
      const angle = (2 * Math.PI * i) / this.cityNames.length - Math.PI / 2;
      return {
        x: centerX + radius * Math.cos(angle),
        y: centerY + radius * Math.sin(angle)
      } as Point;
    });

    // 2. 绘制基础边 (allEdges) - 浅灰色
    ctx.strokeStyle = '#E8E8E8';
    ctx.lineWidth = 1;
    this.allEdges.forEach(edge => {
      this.drawLine(ctx, nodePositions, edge);
    });

    // 3. 绘制生成树边 (根据动画状态)
    if (this.isAnimating) {
      // 动画模式：绘制 0 到 currentStep-1 的边
      ctx.strokeStyle = '#52C41A'; // 绿色
      ctx.lineWidth = 3;
      for (let i = 0; i < this.currentStep; i++) {
        if (this.mstEdges[i]) {
          this.drawLine(ctx, nodePositions, this.mstEdges[i]);
        }
      }
      // 绘制当前正在闪烁/高亮的边 (蓝色)
      if (this.currentStep < this.mstEdges.length) {
        ctx.strokeStyle = '#1890FF';
        ctx.lineWidth = 5;
        this.drawLine(ctx, nodePositions, this.mstEdges[this.currentStep]);
      }
    } else if (this.mstEdges.length > 0) {
      // 静态结果模式
      ctx.strokeStyle = '#52C41A';
      ctx.lineWidth = 3;
      this.mstEdges.forEach(edge => {
        this.drawLine(ctx, nodePositions, edge);
      });
    }

    // 4. 绘制节点
    nodePositions.forEach((pos, i) => {
      // 节点背景
      ctx.beginPath();
      ctx.fillStyle = '#FFFFFF';
      ctx.arc(pos.x, pos.y, 20, 0, 2 * Math.PI);
      ctx.fill();
      // 节点边框
      ctx.strokeStyle = '#333333';
      ctx.lineWidth = 2;
      ctx.stroke();
      // 节点文字
      ctx.fillStyle = '#333333';
      ctx.font = '12px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      // 截取前3个字符防止溢出
      const name = this.cityNames[i] ? this.cityNames[i].substring(0, 3) : '';
      ctx.fillText(name, pos.x, pos.y);
    });
  }

  // 封装画线逻辑
  private drawLine(ctx: CanvasRenderingContext2D, pos: Point[], edge: Edge) {
    if (!edge || edge.from >= pos.length || edge.to >= pos.length) return;
    ctx.beginPath();
    ctx.moveTo(pos[edge.from].x, pos[edge.from].y);
    ctx.lineTo(pos[edge.to].x, pos[edge.to].y);
    ctx.stroke();
  }

  build() {
    Stack() {
      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.isCanvasReady = true;
          this.drawGraph();
        })
    }
    .width('100%')
    .height('100%')
  }
}