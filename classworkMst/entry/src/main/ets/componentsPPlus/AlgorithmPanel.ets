import { AnimationStep, GraphEdge, NodeInfo } from '../model/GraphPPlus';
import { MSTAlgorithms } from '../utils/MSTAlgorithms';

@Component
export struct AlgorithmPanel {
  @Prop nodes: NodeInfo[] = [];
  // 【新增】接收当前视图名称（省份或自定义）
  @Prop currentScopeName: string = "";

  onEdgesUpdate?: (edges: GraphEdge[], latestEdge: GraphEdge | null) => void;

  @State selectedAlgorithm: string = 'Prim';
  @State startNodeIndex: number = 0;
  @State isPlaying: boolean = false;
  @State steps: AnimationStep[] = [];
  @State currentStepIndex: number = -1;
  @State currentMessage: string = "准备就绪";
  @State currentCost: number = 0;

  private timerId: number = -1;

  runAlgorithm() {
    this.stopAnimation();
    if (this.nodes.length < 2) return;

    if (this.selectedAlgorithm === 'Prim') {
      this.steps = MSTAlgorithms.runPrim(this.nodes, this.startNodeIndex);
    } else {
      this.steps = MSTAlgorithms.runKruskal(this.nodes);
    }

    this.currentStepIndex = -1;
    this.currentCost = 0;
    if (this.onEdgesUpdate) this.onEdgesUpdate([], null);
    this.startAnimation();
  }

  startAnimation() {
    if (this.isPlaying) return;
    this.isPlaying = true;
    this.timerId = setInterval(() => {
      if (this.currentStepIndex < this.steps.length - 1) {
        this.currentStepIndex++;
        this.syncStateWithStep(this.currentStepIndex);
      } else {
        this.stopAnimation();
        this.currentMessage = "生成完成";
        // 完成后清除高亮
        if (this.onEdgesUpdate && this.steps.length > 0) {
          this.onEdgesUpdate(this.steps[this.steps.length - 1].edgesSoFar, null);
        }
      }
    }, 1000);
  }

  stopAnimation() {
    this.isPlaying = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  // 【新增】统一的状态同步方法
  syncStateWithStep(index: number) {
    const step = this.steps[index];
    if (!step) return;

    this.currentMessage = step.message;
    // 【优化】进度条拖动时，这里会同步更新权重
    this.currentCost = step.costSoFar;

    // 更新地图
    if (step.type === 'select' || step.type === 'complete' || step.type === 'init') {
      if (this.onEdgesUpdate) {
        const activeEdge = step.type === 'select' ? (step.edge || null) : null;
        this.onEdgesUpdate(step.edgesSoFar, activeEdge);
      }
    }
  }

  build() {
    Column({ space: 10 }) {
      // 1. 顶部：算法与配置
      Row({ space: 10 }) {
        // 左侧：算法选择
        Column() {
          Text("核心算法").fontSize(10).fontColor(Color.Gray).margin({bottom: 4})
          Select([{ value: 'Prim' }, { value: 'Kruskal' }])
            .value(this.selectedAlgorithm)
            .selected(this.selectedAlgorithm === 'Prim' ? 0 : 1)
            .onSelect((index, value) => {
              this.selectedAlgorithm = value;
              this.stopAnimation();
              this.steps = [];
              this.currentMessage = "已切换算法，请点击开始";
              this.currentCost = 0;
              if (this.onEdgesUpdate) this.onEdgesUpdate([], null);
            })
            .height(32).width('100%')
        }.layoutWeight(1)

        // 右侧：根据算法动态显示
        if (this.selectedAlgorithm === 'Prim') {
          Column() {
            Text("Prim 起点").fontSize(10).fontColor(Color.Gray).margin({bottom: 4})
            Select(this.nodes.map((n, i) => { return { value: n.name } as SelectOption }))
              .value(this.nodes.length > 0 ? this.nodes[this.startNodeIndex].name : "")
              .selected(this.startNodeIndex)
              .onSelect((index) => { this.startNodeIndex = index; })
              .height(32).width('100%')
          }.layoutWeight(1)
        } else {
          // 【优化】Kruskal 模式下，右侧显示当前区域名称，保持排版对齐
          Column() {
            Text("当前区域").fontSize(10).fontColor(Color.Gray).margin({bottom: 4})
            Text(this.currentScopeName) // 显示省份名
              .fontSize(14).fontColor('#333')
              .height(32).width('100%')
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .textAlign(TextAlign.Center)
          }.layoutWeight(1)
        }
      }.width('100%')

      Divider().color('#F0F0F0')

      // 2. 中部：控制按钮与状态文字
      Row({ space: 10 }) {
        Button(this.isPlaying ? "暂停" : "开始演示")
          .onClick(() => {
            if (this.isPlaying) this.stopAnimation();
            else if (this.steps.length === 0 || this.currentStepIndex >= this.steps.length - 1) this.runAlgorithm();
            else this.startAnimation();
          })
          .type(ButtonType.Capsule)
          .backgroundColor(this.isPlaying ? '#FF9800' : '#2196F3')
          .width(80).height(32).fontSize(12)

        Column() {
          // 状态文字
          Text(this.currentMessage)
            .fontSize(12).fontColor('#333')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

          // 【优化】这里补充算法说明
          Row() {
            Text(`总权重: ${this.currentCost.toFixed(2)}`)
              .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#4CAF50').margin({right: 10})

            // 如果是 Kruskal，在这里显示策略说明
            if (this.selectedAlgorithm === 'Kruskal') {
              Text("(全局贪心策略)").fontSize(10).fontColor(Color.Gray)
            }
          }
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      }.width('100%')

      // 3. 进度条
      if (this.steps.length > 0) {
        Row() {
          Text("进度").fontSize(10).fontColor(Color.Gray).margin({right: 5})
          Slider({
            value: this.currentStepIndex,
            min: 0,
            max: this.steps.length - 1
          })
            .layoutWeight(1)
            .onChange((value) => {
              this.stopAnimation();
              const newIndex = Math.floor(value);
              this.currentStepIndex = newIndex;
              // 【优化】拖动时同步更新所有状态（包括权重、地图、文字）
              this.syncStateWithStep(newIndex);
            })
        }.width('100%')
      }
    }
    .padding(14)
    .backgroundColor('rgba(255,255,255,0.98)')
    .borderRadius(16)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
  }
}