/**
 * 结果边列表 + 总代价显示面板
 */


interface EdgeListInterface {
  from: number;
  to: number;
  weight: number;
}


@Component
export struct EdgeListPanel {
  // 边列表
  private edges: EdgeListInterface[] = [];
  // 城市名称列表
  private cityNames: string[] = [];
  // 总代价
  private totalCost: number = 0;
  // 是否显示面板
  private isVisible: boolean = true;

  // 设置边列表
  setEdges(edges: EdgeListInterface[]): void {
    this.edges = edges;
  }

  // 设置城市名称
  setCityNames(names: string[]): void {
    this.cityNames = names;
  }

  // 设置总代价
  setTotalCost(cost: number): void {
    this.totalCost = cost;
  }

  // 设置可见性
  setVisible(visible: boolean): void {
    this.isVisible = visible;
  }

  build() {
    if(this.isVisible) {
      Column() {
        // 标题
        Row() {
          Text('最小生成树结果')
            .fontSize(18)
            .fontWeight(500)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })

        // 边列表
        Scroll() {
          Column() {
            ForEach(this.edges, (edge: EdgeListInterface, index: number) => {
              Column() {
                Row() {
                  Text(`${index + 1}.`)
                    .fontSize(14)
                    .width(30)

                  Text(`${this.cityNames[edge.from] || '未知'} - ${this.cityNames[edge.to] || '未知'}`)
                    .fontSize(14)
                    .layoutWeight(1)

                  Text(`${edge.weight}`)
                    .fontSize(14)
                    .width(50)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .padding({ left: 10, right: 10 })

                Divider()
                  .margin({ top: 5, bottom: 5 })
              }
            })
          }
        }
        .layoutWeight(1)
        .width('100%')

        // 总代价
        Row() {
          Text('总代价:')
            .fontSize(16)
            .fontWeight(500)

          Text(`${this.totalCost}`)
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#007DFF')
            .margin({ left: 10 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 10, bottom: 10 })
      }
      .width('100%')
      .height('40%')
      .backgroundColor('#F1F3F5')
      .borderRadius(20)
      .shadow({
        radius: 10,
        offsetX: 0,
        offsetY: 5,
        color: '#00000020'
      })
      .padding(10)
    }
  }
}