import { TransportType } from '../model/MapData';

@Component
export struct ControlPanel {
  @Link transportType: TransportType;
  @Link selectedAlgorithm: string;
  @Link animationSpeed: number;
  @Link useTimeWeight: boolean;

  // 接收城市列表和起点索引
  @Prop cityNames: string[] = [];
  @Link startNodeIndex: number;

  onStartAnimation: () => void = () => {};
  onPauseAnimation: () => void = () => {};
  onResetAnimation: () => void = () => {};
  onStepForward: () => void = () => {};
  onOpenFullScreen: () => void = () => {};

  @Prop isAnimating: boolean = false;
  @Prop isPaused: boolean = false;

  build() {
    Column({ space: 16 }) {
      // 标题
      Text('最小生成树演示')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      // 交通方式选择
      Column({ space: 8 }) {
        Text('交通方式')
          .fontSize(14)
          .fontColor('#666666')

        Row({ space: 12 }) {
          Button(this.transportType === TransportType.HIGHWAY ? '✓ 高速公路' : '高速公路')
            .type(ButtonType.Normal)
            .backgroundColor(this.transportType === TransportType.HIGHWAY ? '#1565C0' : '#E0E0E0')
            .fontColor(this.transportType === TransportType.HIGHWAY ? '#FFFFFF' : '#333333')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.transportType = TransportType.HIGHWAY;
            })

          Button(this.transportType === TransportType.RAILWAY ? '✓ 铁路' : '铁路')
            .type(ButtonType.Normal)
            .backgroundColor(this.transportType === TransportType.RAILWAY ? '#5D4037' : '#E0E0E0')
            .fontColor(this.transportType === TransportType.RAILWAY ? '#FFFFFF' : '#333333')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.transportType = TransportType.RAILWAY;
            })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 算法选择
      Column({ space: 8 }) {
        Text('算法选择')
          .fontSize(14)
          .fontColor('#666666')

        Row({ space: 12 }) {
          Button(this.selectedAlgorithm === 'prim' ? '✓ Prim' : 'Prim')
            .type(ButtonType.Normal)
            .backgroundColor(this.selectedAlgorithm === 'prim' ? '#4CAF50' : '#E0E0E0')
            .fontColor(this.selectedAlgorithm === 'prim' ? '#FFFFFF' : '#333333')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.selectedAlgorithm = 'prim';
            })

          Button(this.selectedAlgorithm === 'kruskal' ? '✓ Kruskal' : 'Kruskal')
            .type(ButtonType.Normal)
            .backgroundColor(this.selectedAlgorithm === 'kruskal' ? '#9C27B0' : '#E0E0E0')
            .fontColor(this.selectedAlgorithm === 'kruskal' ? '#FFFFFF' : '#333333')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.selectedAlgorithm = 'kruskal';
            })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // --- 起点选择 (仅 Prim 有效) ---
      if (this.selectedAlgorithm === 'prim') {
        Column({ space: 8 }) {
          Text('Prim 起始城市')
            .fontSize(14)
            .fontColor('#666666')

          // 修复点：显式声明 map 的返回类型并进行类型断言
          Select(this.cityNames.map((name: string): SelectOption => {
            return { value: name } as SelectOption;
          }))
            .selected(this.startNodeIndex)
            .value(this.cityNames[this.startNodeIndex])
            .font({ size: 14 })
            .fontColor('#333333')
            .selectedOptionFont({ size: 14 })
            .optionFont({ size: 14 })
            .height(36)
            .width('100%')
            .onSelect((index: number) => {
              this.startNodeIndex = index;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      // ------------------------------------

      // 权重类型
      Column({ space: 8 }) {
        Text('权重类型')
          .fontSize(14)
          .fontColor('#666666')

        Row({ space: 12 }) {
          Button(this.useTimeWeight ? '距离(km)' : '✓ 距离(km)')
            .type(ButtonType.Normal)
            .backgroundColor(!this.useTimeWeight ? '#FF9800' : '#E0E0E0')
            .fontColor(!this.useTimeWeight ? '#FFFFFF' : '#333333')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.useTimeWeight = false;
            })

          Button(this.useTimeWeight ? '✓ 时间(分钟)' : '时间(分钟)')
            .type(ButtonType.Normal)
            .backgroundColor(this.useTimeWeight ? '#FF9800' : '#E0E0E0')
            .fontColor(this.useTimeWeight ? '#FFFFFF' : '#333333')
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.useTimeWeight = true;
            })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 动画速度
      Column({ space: 8 }) {
        Row() {
          Text('动画速度')
            .fontSize(14)
            .fontColor('#666666')

          Blank()

          Text(this.getSpeedLabel())
            .fontSize(14)
            .fontColor('#2196F3')
        }
        .width('100%')

        Slider({
          value: this.animationSpeed,
          min: 100,
          max: 2000,
          step: 100
        })
          .onChange((value: number) => {
            this.animationSpeed = value;
          })
          .blockColor('#2196F3')
          .trackColor('#E0E0E0')
          .selectedColor('#2196F3')
      }
      .width('100%')

      Divider().color('#E0E0E0')

      // 控制按钮
      Column({ space: 12 }) {
        Row({ space: 12 }) {
          Button(this.isAnimating && !this.isPaused ? '暂停' : '开始演示')
            .type(ButtonType.Normal)
            .width('45%')
            .height(44)
            .backgroundColor(this.isAnimating && !this.isPaused ? '#FF9800' : '#4CAF50')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .onClick(() => {
              if (this.isAnimating && !this.isPaused) {
                this.onPauseAnimation();
              } else {
                this.onStartAnimation();
              }
            })

          Button('重置')
            .type(ButtonType.Normal)
            .width('45%')
            .height(44)
            .backgroundColor('#F44336')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .onClick(() => {
              this.onResetAnimation();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row({ space: 12 }) {
          Button('单步执行')
            .type(ButtonType.Normal)
            .width('45%')
            .height(44)
            .backgroundColor('#2196F3')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .enabled(!this.isAnimating || this.isPaused)
            .opacity(!this.isAnimating || this.isPaused ? 1 : 0.5)
            .onClick(() => {
              this.onStepForward();
            })

          Button('全屏查看')
            .type(ButtonType.Normal)
            .width('45%')
            .height(44)
            .backgroundColor('#673AB7')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .onClick(() => {
              this.onOpenFullScreen();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
  }

  private getSpeedLabel(): string {
    if (this.animationSpeed <= 300) return '快速';
    if (this.animationSpeed <= 800) return '中速';
    if (this.animationSpeed <= 1500) return '慢速';
    return '非常慢';
  }
}