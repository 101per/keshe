/**
 * 简单圆形布局的节点+边可视化组件
 */

// 定义边的接口
interface Edge {
  from: number;
  to: number;
  weight: number;
}

// 定义点的接口
interface Point {
  x: number;
  y: number;
}

@Component
export struct GraphVisualizer {
  // 使用 @Prop 装饰器
  @Prop cityNames: string[] = [];
  @Prop allEdges: Edge[] = [];
  @Prop mstEdges: Edge[] = [];
  @Prop isAnimating: boolean = false;
  @Prop currentStep: number = 0;
  @Prop rejectedEdges: Edge[] = [];
  @Prop highlightedEdge: Edge | null = null;

  // Canvas 上下文
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  // 标记 Canvas 是否已准备就绪
  private isCanvasReady: boolean = false;
  // 用于触发重绘的状态
  @State refreshCounter: number = 0;

  // 计算节点在圆形布局中的位置
  private calculateNodePosition(index: number, total: number, centerX: number, centerY: number,
    radius: number): Point {
    const angle = (2 * Math.PI * index) / total - Math.PI / 2;
    return {
      x: centerX + radius * Math.cos(angle),
      y: centerY + radius * Math.sin(angle)
    };
  }

  // 绘制图形
  private drawGraph(): void {
    const canvas = this.canvasContext;
    if (!canvas || !this.cityNames || this.cityNames.length === 0) {
      return;
    }

    const width = canvas.width;
    const height = canvas.height;
    const centerX = width / 2;
    const centerY = height / 2;
    const radius = Math.min(width, height) / 2 - 23;
    const nodeRadius = 22;

    // 清空画布
    canvas.clearRect(0, 0, width, height);

    const nodePositions = this.cityNames.map((_, index) =>
    this.calculateNodePosition(index, this.cityNames.length, centerX, centerY, radius)
    );

    // 绘制所有边（灰色）- 仅在非动画模式下显示
    if (!this.isAnimating) {
      canvas.strokeStyle = '#CCCCCC';
      canvas.lineWidth = 1;
      if (this.allEdges) {
        for (const edge of this.allEdges) {
          if (edge.from < nodePositions.length && edge.to < nodePositions.length) {
            const fromPos = nodePositions[edge.from];
            const toPos = nodePositions[edge.to];

            const path = new Path2D();
            path.moveTo(fromPos.x, fromPos.y);
            path.lineTo(toPos.x, toPos.y);
            canvas.stroke(path);
          }
        }
      }
    }

    // 绘制拒绝的边（红色）
    canvas.strokeStyle = '#FF0000';
    canvas.lineWidth = 2;
    if (this.rejectedEdges) {
      for (const edge of this.rejectedEdges) {
        if (edge.from < nodePositions.length && edge.to < nodePositions.length) {
          const fromPos = nodePositions[edge.from];
          const toPos = nodePositions[edge.to];

          const path = new Path2D();
          path.moveTo(fromPos.x, fromPos.y);
          path.lineTo(toPos.x, toPos.y);
          canvas.stroke(path);
        }
      }
    }

    // 根据动画状态绘制MST边
    if (this.isAnimating && this.mstEdges.length > 0) {
      // 绘制已添加的边（绿色）
      canvas.strokeStyle = '#00FF00';
      canvas.lineWidth = 3;
      for (let i = 0; i < Math.min(this.currentStep, this.mstEdges.length); i++) {
        const edge = this.mstEdges[i];
        if (edge.from < nodePositions.length && edge.to < nodePositions.length) {
          const fromPos = nodePositions[edge.from];
          const toPos = nodePositions[edge.to];

          const path = new Path2D();
          path.moveTo(fromPos.x, fromPos.y);
          path.lineTo(toPos.x, toPos.y);
          canvas.stroke(path);
        }
      }

      // 绘制当前正在添加的边（蓝色高亮）
      if (this.currentStep < this.mstEdges.length) {
        const currentEdge = this.mstEdges[this.currentStep];
        if (currentEdge.from < nodePositions.length && currentEdge.to < nodePositions.length) {
          const fromPos = nodePositions[currentEdge.from];
          const toPos = nodePositions[currentEdge.to];

          canvas.strokeStyle = '#0000FF';
          canvas.lineWidth = 4;
          const path = new Path2D();
          path.moveTo(fromPos.x, fromPos.y);
          path.lineTo(toPos.x, toPos.y);
          canvas.stroke(path);
        }
      }
    } else {
      // 非动画模式下，绘制所有MST边（绿色）
      canvas.strokeStyle = '#00FF00';
      canvas.lineWidth = 3;
      if (this.mstEdges) {
        for (const edge of this.mstEdges) {
          if (edge.from < nodePositions.length && edge.to < nodePositions.length) {
            const fromPos = nodePositions[edge.from];
            const toPos = nodePositions[edge.to];

            const path = new Path2D();
            path.moveTo(fromPos.x, fromPos.y);
            path.lineTo(toPos.x, toPos.y);
            canvas.stroke(path);
          }
        }
      }
    }

    // 绘制高亮边（蓝色）
    if (this.highlightedEdge) {
      canvas.strokeStyle = '#0000FF';
      canvas.lineWidth = 4;
      if (this.highlightedEdge.from < nodePositions.length && this.highlightedEdge.to < nodePositions.length) {
        const fromPos = nodePositions[this.highlightedEdge.from];
        const toPos = nodePositions[this.highlightedEdge.to];

        const path = new Path2D();
        path.moveTo(fromPos.x, fromPos.y);
        path.lineTo(toPos.x, toPos.y);
        canvas.stroke(path);
      }
    }

    // 绘制节点
    canvas.fillStyle = '#FFFFFF';
    canvas.strokeStyle = '#000000';
    canvas.lineWidth = 2;

    for (let i = 0; i < this.cityNames.length; i++) {
      const pos = nodePositions[i];

      // 绘制节点圆形
      const path = new Path2D();
      path.arc(pos.x, pos.y, nodeRadius, 0, 2 * Math.PI);
      canvas.fill(path);
      canvas.stroke(path);

      // 绘制节点标签
      canvas.fillStyle = '#000000';
      canvas.font = '10px sans-serif';
      canvas.textAlign = 'center';
      canvas.textBaseline = 'middle';
      const cityName = this.cityNames[i];
      canvas.fillText(cityName && cityName.length > 3 ? cityName.substring(0, 3) : (cityName || ''), pos.x, pos.y);
      canvas.fillStyle = '#FFFFFF';
    }
  }

  aboutToAppear() {
    // 组件即将出现时，确保绘制最新的数据
    // 延迟绘制以确保属性已更新
    setTimeout(() => {
      if (this.isCanvasReady) {
        this.drawGraph();
      }
    }, 10);
  }

  aboutToUpdate() {
    // 当组件属性更新时，立即更新数据并重绘
    // 延迟绘制以确保属性已完全更新
    setTimeout(() => {
      if (this.isCanvasReady) {
        this.drawGraph();
      }
    }, 10);
  }

  updateState(cityNames: string[], allEdges: Edge[], mstEdges: Edge[], rejectedEdges: Edge[], highlightedEdge: Edge | null) {
    this.cityNames = cityNames;
    this.allEdges = allEdges;
    this.mstEdges = mstEdges;
    this.rejectedEdges = rejectedEdges;
    this.highlightedEdge = highlightedEdge;
    
    if (this.isCanvasReady) {
      this.drawGraph();
    }
  }

  build() {
    Column() {
      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.isCanvasReady = true;
          this.drawGraph();
        })
        .onSizeChange(() => {
          this.drawGraph();
        })
        .key(`canvas-${this.refreshCounter}`) // 使用 refreshCounter 确保 Canvas 重新渲染
    }
    .width('100%')
    .height('100%')
  }
}