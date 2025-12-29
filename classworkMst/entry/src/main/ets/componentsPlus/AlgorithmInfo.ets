// 引入 GraphEdge
import { AnimationStep, GraphEdge } from '../model/GraphPlus';

@Component
export struct AlgorithmInfo {
  @Prop algorithmName: string = 'Prim';
  @Prop currentStep: AnimationStep | null = null;
  @Prop totalSteps: number = 0;
  @Prop currentStepIndex: number = 0;
  // 修改为 GraphEdge[]
  @Prop mstEdges: GraphEdge[] = [];
  @Prop totalCost: number = 0;
  @Prop cityNames: string[] = [];

  @State expandedLog: boolean = false;

  build() {
    Column({ space: 12 }) {
      // ... 头部保持不变 ...
      Row() {
        Text(`${this.algorithmName} 算法`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Blank()
        if (this.totalSteps > 0) {
          Text(`步骤: ${this.currentStepIndex + 1}/${this.totalSteps}`)
            .fontSize(14)
            .fontColor('#666666')
        }
      }.width('100%')

      if (this.totalSteps > 0) {
        Progress({
          value: this.currentStepIndex + 1,
          total: this.totalSteps,
          type: ProgressType.Linear
        })
          .width('100%')
          .height(8)
          .color('#4CAF50')
          .backgroundColor('#E0E0E0')
      }

      if (this.currentStep) {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(this.getStepIcon())
              .fontSize(20)
            Text(this.currentStep.message)
              .fontSize(14)
              .fontColor(this.getStepColor())
              .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.getStepBackgroundColor())
          .borderRadius(8)
        }
      }

      Divider().color('#E0E0E0')

      // ... 统计部分保持不变 ...
      Row({ space: 20 }) {
        // ... 省略重复代码 ...
      }.width('100%').justifyContent(FlexAlign.SpaceAround)

      // 已选边列表
      if (this.mstEdges.length > 0) {
        Column({ space: 8 }) {
          Row() {
            Text('已选择的边')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Blank()
            Text(this.expandedLog ? '收起' : '展开')
              .fontSize(12)
              .fontColor('#2196F3')
              .onClick(() => {
                this.expandedLog = !this.expandedLog;
              })
          }.width('100%')

          if (this.expandedLog) {
            Scroll() {
              Column({ space: 4 }) {
                // 类型修改为 GraphEdge
                ForEach(this.mstEdges, (edge: GraphEdge, index: number) => {
                  Row({ space: 8 }) {
                    Text(`${index + 1}.`)
                      .fontSize(12)
                      .fontColor('#999999')
                      .width(24)
                    Text(`${this.cityNames[edge.from]}`)
                      .fontSize(12)
                      .fontColor('#333333')
                    Text('→')
                      .fontSize(12)
                      .fontColor('#999999')
                    Text(`${this.cityNames[edge.to]}`)
                      .fontSize(12)
                      .fontColor('#333333')
                    Blank()
                    Text(`${edge.weight}`)
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                  .padding({ top: 4, bottom: 4 })
                })
              }
            }
            .height(120)
            .scrollBar(BarState.Auto)
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
  }

  // ... 辅助方法保持不变 ...
  private getStepIcon(): string {
    switch (this.currentStep?.type) {
      case 'check': return '🔍';
      case 'select': return '✅';
      case 'reject': return '❌';
      case 'complete': return '🎉';
      default: return '📍';
    }
  }

  private getStepColor(): string {
    switch (this.currentStep?.type) {
      case 'check': return '#FF9800';
      case 'select': return '#4CAF50';
      case 'reject': return '#F44336';
      case 'complete': return '#2196F3';
      default: return '#333333';
    }
  }

  private getStepBackgroundColor(): string {
    switch (this.currentStep?.type) {
      case 'check': return '#FFF3E0';
      case 'select': return '#E8F5E9';
      case 'reject': return '#FFEBEE';
      case 'complete': return '#E3F2FD';
      default: return '#F5F5F5';
    }
  }
}