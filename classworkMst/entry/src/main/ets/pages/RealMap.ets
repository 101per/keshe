/**
 * 真实地图模式页面
 * 注意：请先在 module.json5 中配置 Map Kit 服务，并在 AppGallery Connect 获取并填写 API Key
 * 否则地图无法显示
 */
import { EdgeListPanel } from '../components/EdgeListPanel';
import { CitySelector } from '../components/CitySelector';
import { CityData, City } from '../model/CityData';
import { Graph } from '../model/Graph';
import promptAction from '@ohos.promptAction';

// 边接口定义
interface Edge {
  from: number;
  to: number;
  weight: number;
}

// EdgeListPanel组件props接口
interface EdgeListPanelProps {
  cityNames: string[];
  edges: Edge[];
  totalCost: number;
  isVisible: boolean;
}

// CitySelector组件props接口
interface CitySelectorProps {
  selectedIndices: number[];
  onSelectionChange: (indices: number[]) => void;
}

@Component
export default struct RealMap {
  // 选中的城市
  @State selectedCities: City[] = [];
  // 选中的城市索引
  @State selectedIndices: number[] = [];
  // MST结果边
  @State mstEdges: Edge[] = [];
  // 总代价
  @State totalCost: number = 0;
  // 是否显示结果面板
  @State showResultPanel: boolean = false;
  // 是否显示城市选择器
  @State showCitySelector: boolean = false;

  aboutToAppear(): void {
    // 初始化可以放在这里，比如加载上次选择的城市
  }

  // 处理城市选择变化
  private handleCitySelectionChange(indices: number[]): void {
    this.selectedIndices = indices;
    this.selectedCities = indices.map(index => CityData.CITIES[index]);
  }

  // 创建城市名称数组
  private getCityNames(): string[] {
    return this.selectedCities.map(city => city.name);
  }

  // 计算MST
  private calculateMST(): void {
    if (this.selectedCities.length < 2) {
      promptAction.showToast({
        message: '请至少选择两个城市',
        duration: 2000
      });
      return;
    }

    try {
      // 构建图数据
      const cityNames: string[] = this.getCityNames();
      const graph: Graph = new Graph();

      // 初始化邻接矩阵
      const size: number = this.selectedCities.length;
      const matrix: number[][] = new Array(size);

      for (let i = 0; i < size; i++) {
        matrix[i] = new Array(size);
        for (let j = 0; j < size; j++) {
          matrix[i][j] = Infinity;
        }
      }

      // 计算城市间距离
      for (let i = 0; i < size; i++) {
        for (let j = i + 1; j < size; j++) {
          const distance: number = CityData.haversineDistance(this.selectedCities[i], this.selectedCities[j]);
          matrix[i][j] = distance;
          matrix[j][i] = distance;
        }
      }

      // 对角线设为0
      for (let i = 0; i < size; i++) {
        matrix[i][i] = 0;
      }

      graph.initialize(cityNames, matrix);

      // 执行Kruskal算法
      const result = graph.kruskal();
      this.mstEdges = result.edges;
      this.totalCost = result.cost;
      this.showResultPanel = true;

      promptAction.showToast({
        message: `MST计算完成，总距离: ${this.totalCost.toFixed(2)} km`,
        duration: 2000
      });

    } catch (error) {
      const errorMessage: string = error instanceof Error ? error.message : '计算MST时发生错误';
      promptAction.showToast({
        message: errorMessage,
        duration: 2000
      });
    }
  }

  // 清空选择
  private clearSelection(): void {
    this.selectedCities = [];
    this.selectedIndices = [];
    this.mstEdges = [];
    this.totalCost = 0;
    this.showResultPanel = false;
  }

  // 获取EdgeListPanel组件的props
  private getEdgeListPanelProps(): EdgeListPanelProps {
    return {
      cityNames: this.getCityNames(),
      edges: this.mstEdges,
      totalCost: this.totalCost,
      isVisible: this.showResultPanel
    };
  }

  // 获取CitySelector组件的props
  private getCitySelectorProps(): CitySelectorProps {
    return {
      selectedIndices: this.selectedIndices,
      onSelectionChange: (indices: number[]) => this.handleCitySelectionChange(indices)
    };
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('真实地图MST计算')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 10 })

      // 控制按钮
      Row() {
        Button('选择城市')
          .onClick(() => {
            this.showCitySelector = true;
          })

        Button('计算')
          .onClick(() => {
            this.calculateMST();
          })
          .margin({ left: 10 })

        Button('清空')
          .onClick(() => {
            this.clearSelection();
          })
          .margin({ left: 10 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20, bottom: 10 })

      // 已选城市显示
      if (this.selectedCities.length > 0) {
        Column() {
          Text('已选城市:')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })

          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(this.selectedCities, (city: City, index: number) => {
              Text(city.name)
                .fontSize(12)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(Color.Blue)
                .fontColor(Color.White)
                .borderRadius(10)
                .margin({ right: 5, bottom: 5 })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(10)
        .margin({ bottom: 10 })
      }

      // 地图容器（占位符，实际应使用Map Kit组件）
      Column() {
        Text('地图显示区域')
          .fontSize(16)
          .fontColor('#888888')

        Text('（需要配置Map Kit服务并填写API Key）')
          .fontSize(12)
          .fontColor('#AAAAAA')
          .margin({ top: 5 })
      }
      .width('100%')
      .height('60%')
      .backgroundColor('#F0F0F0')
      .justifyContent(FlexAlign.Center)

      // 结果面板
      if (this.showResultPanel) {
        EdgeListPanel(this.getEdgeListPanelProps())
          .width('100%')
          .margin({ top: 10 })
      }

      // 城市选择器弹窗
      if (this.showCitySelector) {
        Column() {
          // 标题栏
          Row() {
            Text('选择城市')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('×')
              .fontSize(18)
              .width(30)
              .height(30)
              .onClick(() => {
                this.showCitySelector = false;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#F5F5F5')

          // 城市选择器
          CitySelector(this.getCitySelectorProps())
            .height('70%')

          // 按钮区域
          Row() {
            Button('取消')
              .layoutWeight(1)
              .onClick(() => {
                this.showCitySelector = false;
              })

            Button('确定')
              .layoutWeight(1)
              .margin({ left: 10 })
              .onClick(() => {
                this.showCitySelector = false;
                promptAction.showToast({
                  message: `已选择${this.selectedCities.length}个城市`,
                  duration: 1500
                });
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 10 })
        }
        .width('90%')
        .height('80%')
        .backgroundColor(Color.White)
        .borderRadius(10)
        .position({ x: '5%', y: '10%' })
        .shadow({ radius: 20, color: '#888888', offsetX: 0, offsetY: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }
}