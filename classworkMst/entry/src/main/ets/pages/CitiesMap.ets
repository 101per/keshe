import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import { Graph, MSTResult, AnimationStep, GraphEdge } from '../model/GraphPlus';
import { ChinaMapData, TransportType } from '../model/MapData';
import { MapCanvas } from '../componentsPlus/MapCanvas';
import { ControlPanel } from '../componentsPlus/ControlPanel';
import { AlgorithmInfo } from '../componentsPlus/AlgorithmInfo';


@Component
export struct CitiesMap {
  @State transportType: TransportType = TransportType.RAILWAY;
  @State selectedAlgorithm: string = 'prim';
  @State animationSpeed: number = 800;
  @State useTimeWeight: boolean = false;

  @State startNodeIndex: number = 0;

  @State isAnimating: boolean = false;
  @State isPaused: boolean = false;
  @State currentStepIndex: number = -1;
  @State currentStep: AnimationStep | null = null;
  @State mstResult: MSTResult | null = null;
  @State displayedEdges: GraphEdge[] = [];

  private graph: Graph = new Graph();
  private animationTimer: number = -1;

  aboutToAppear() {
    this.initializeGraph();
  }

  aboutToDisappear() {
    this.stopAnimation();
  }

  private initializeGraph() {
    const cityNames = ChinaMapData.getCityNames();
    const matrix = ChinaMapData.getAdjacencyMatrix(this.transportType, this.useTimeWeight);
    this.graph.initialize(cityNames, matrix);
  }

  private startAnimation() {
    this.initializeGraph();

    if (this.selectedAlgorithm === 'prim') {
      this.mstResult = this.graph.primWithAnimation(this.startNodeIndex);
    } else {
      this.mstResult = this.graph.kruskalWithAnimation();
    }

    this.currentStepIndex = -1;
    this.displayedEdges = [];
    this.isAnimating = true;
    this.isPaused = false;
    this.runNextStep();
  }

  private runNextStep() {
    if (!this.mstResult || !this.isAnimating || this.isPaused) return;

    // 修复 1: 先检查是否到达最后一步，防止溢出
    if (this.currentStepIndex >= this.mstResult.steps.length - 1) {
      this.isAnimating = false;
      return;
    }

    // 只有没到最后一步，才增加索引
    this.currentStepIndex++;

    const step = this.mstResult.steps[this.currentStepIndex];
    this.currentStep = step;

    if (step.type === 'select' && step.edge.from >= 0) {
      let newEdges: GraphEdge[] = [];
      for (let e of this.displayedEdges) {
        newEdges.push(e);
      }
      newEdges.push(step.edge);
      this.displayedEdges = newEdges;
    }

    this.animationTimer = setTimeout(() => {
      this.runNextStep();
    }, this.animationSpeed);
  }

  private pauseAnimation() {
    this.isPaused = true;
    if (this.animationTimer !== -1) {
      clearTimeout(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  private resumeAnimation() {
    this.isPaused = false;
    this.runNextStep();
  }

  private stepForward() {
    if (!this.mstResult) {
      this.initializeGraph();
      if (this.selectedAlgorithm === 'prim') {
        this.mstResult = this.graph.primWithAnimation(this.startNodeIndex);
      } else {
        this.mstResult = this.graph.kruskalWithAnimation();
      }
      this.currentStepIndex = -1;
      this.displayedEdges = [];
    }

    // 修复 2: 单步执行时，先检查是否已是最后一步
    if (this.currentStepIndex >= this.mstResult.steps.length - 1) {
      // 已经结束了，直接返回，不再增加索引
      return;
    }

    this.currentStepIndex++;

    const step = this.mstResult.steps[this.currentStepIndex];
    this.currentStep = step;
    if (step.type === 'select' && step.edge.from >= 0) {
      let newEdges: GraphEdge[] = [];
      for (let e of this.displayedEdges) {
        newEdges.push(e);
      }
      newEdges.push(step.edge);
      this.displayedEdges = newEdges;
    }
  }

  private resetAnimation() {
    this.stopAnimation();
    this.currentStepIndex = -1;
    this.currentStep = null;
    this.mstResult = null;
    this.displayedEdges = [];
    this.isAnimating = false;
    this.isPaused = false;
  }

  private stopAnimation() {
    if (this.animationTimer !== -1) {
      clearTimeout(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  private openFullScreen() {
    const edgesJson = JSON.stringify(this.displayedEdges);

    router.pushUrl({
      url: 'pages/FullScreenMap',
      params: {
        transportType: this.transportType,
        mstEdgesStr: edgesJson,
        cityNames: ChinaMapData.getCityNames()
      }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败 code:${err.code}, msg:${err.message}`);
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('🗺️ 交通网络最小生成树')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .backgroundColor('#1976D2')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)

      // 主内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 地图区域
          Column() {
            MapCanvas({
              mapWidth: 360,
              mapHeight: 450,
              transportType: this.transportType,
              mstEdges: this.displayedEdges,
              currentStep: this.currentStep,
              showAllEdges: true,
              isAnimating: this.isAnimating
            })
          }
          .width('100%')
          .padding(8)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
          .onClick(() => {
            this.openFullScreen();
          })

          // 算法信息面板
          AlgorithmInfo({
            algorithmName: this.selectedAlgorithm === 'prim' ? 'Prim' : 'Kruskal',
            currentStep: this.currentStep,
            // 修复 3 (可选): 如果你非常介意最后那个"完成"步骤导致总数+1，
            // 可以在这里显示 totalSteps - 1，但这会导致进度条最后一段走不满。
            // 建议保留原始总数，因为"完成"也是一个明确的状态。
            totalSteps: this.mstResult ? this.mstResult.steps.length : 0,
            currentStepIndex: this.currentStepIndex,
            mstEdges: this.displayedEdges,
            totalCost: this.displayedEdges.reduce((sum, e) => sum + e.weight, 0),
            cityNames: ChinaMapData.getCityNames()
          })

          // 控制面板
          ControlPanel({
            transportType: $transportType,
            selectedAlgorithm: $selectedAlgorithm,
            animationSpeed: $animationSpeed,
            useTimeWeight: $useTimeWeight,

            startNodeIndex: $startNodeIndex,
            cityNames: ChinaMapData.getCityNames(),

            isAnimating: this.isAnimating,
            isPaused: this.isPaused,

            onStartAnimation: (): void => {
              if (this.isPaused) this.resumeAnimation();
              else this.startAnimation();
            },
            onPauseAnimation: (): void => this.pauseAnimation(),
            onResetAnimation: (): void => this.resetAnimation(),
            onStepForward: (): void => this.stepForward(),
            onOpenFullScreen: (): void => this.openFullScreen()
          })
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F0F4F8')
    }
    .width('100%')
    .height('100%')
  }
}