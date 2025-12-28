/**
 * 算法演示模式页面
 */
import { MatrixEditor } from '../components/MatrixEditor';
import { GraphVisualizer } from '../components/GraphVisualizer';
import { Graph } from '../model/Graph';
import { CommonUtils } from '../utils/CommonUtils';
import { FileStorage } from '../model/FileStorage';
import promptAction from '@ohos.promptAction';
interface Edge {
  from: number;
  to: number;
  weight: number;
}

// 算法执行结果接口
interface AlgorithmResult {
  edges: Edge[];
  cost: number;
}

// Select选项接口
interface SelectOption {
  value: string;
  label: string;
}

// 图数据接口
interface GraphData {
  cityNames: string[];
  matrix: number[][];
}

// 矩阵变化回调函数类型
type MatrixChangeCallback = (matrix: number[][]) => void;

// MatrixEditor组件props接口
interface MatrixEditorProps {
  cityNames: string[];
  matrix: number[][];
  onChange: MatrixChangeCallback;
}

// GraphVisualizer组件props接口
interface GraphVisualizerProps {
  cityNames: string[];
  allEdges: Edge[];
  mstEdges: Edge[];
}

@Component
export struct AlgorithmDemo {
  // 城市名称列表
  @State cityNames: string[] = this.initializeCityNames();
  // 邻接矩阵
  @State adjacencyMatrix: number[][] = [];
  // 图实例
  private graph: Graph = new Graph();
  // 算法类型
  @State algorithmType: string = 'prim';
  // 起始节点索引
  @State startNodeIndex: number = 0;
  // MST结果边
  @State mstEdges: Edge[] = [];
  // 总代价
  @State totalCost: number = 0;
  // 是否显示结果面板
  @State showResultPanel: boolean = false;
  // 所有边的列表（用于可视化）
  @State allEdges: Edge[] = [];
  // 组件刷新计数器
  @State refreshCounter: number = 0;
  
  // 图可视化组件的显隐控制
  @State graphVisible: boolean = true;

  // 算法选项
  private algorithmOptions: SelectOption[] = [
    { value: 'prim', label: 'Prim算法' },
    { value: 'kruskal', label: 'Kruskal算法' }
  ];

  // 当前选择的起始节点值
  @State startNodeValue: string = '0';

  // 初始化城市名称
  private initializeCityNames(): string[] {
    const names: string[] = [];
    for (let i = 0; i < 8; i++) {
      names.push(`城市${i + 1}`);
    }
    return names;
  }

  aboutToAppear(): void {
    // 初始化图数据
    this.initializeGraph();
  }

  // 初始化图
  private initializeGraph(): void {
    // 生成随机连通图
    const matrix: number[][] = CommonUtils.generateRandomConnectedGraph(this.cityNames.length);
    this.graph.initialize(this.cityNames, matrix);
    this.adjacencyMatrix = matrix;

    // 更新所有边
    this.updateAllEdges();
  }

  // 更新所有边的列表
  private updateAllEdges(): void {
    const edges: Edge[] = [];
    const n: number = this.cityNames.length;

    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        if (this.adjacencyMatrix && i < this.adjacencyMatrix.length && j < this.adjacencyMatrix[i].length) {
          const row: number[] = this.adjacencyMatrix[i];
          if (row && row[j] !== undefined && row[j] !== Infinity && row[j] > 0) {
            const edge: Edge = {
              from: i,
              to: j,
              weight: row[j]
            };
            edges.push(edge);
          }
        }
      }
    }

    this.allEdges = edges;
  }

  // 处理矩阵变化
  private handleMatrixChange(matrix: number[][]): void {
    this.adjacencyMatrix = matrix;
    this.graph.initialize(this.cityNames, matrix);
    this.updateAllEdges();
    this.showResultPanel = false; // 隐藏结果面板
    
    // 强制刷新组件 - 通过显隐控制强制重新渲染
    this.graphVisible = false;
    
    // 短暂延迟后重新显示，确保组件完全重建
    setTimeout(() => {
      this.graphVisible = true;
    }, 50);
  }

  // 随机生成连通图
  private generateRandomGraph(): void {

    // 重新初始化图数据
    this.initializeGraph();
    this.showResultPanel = false;

    // 强制刷新组件 - 通过显隐控制强制重新渲染
    this.graphVisible = false;
    
    // 短暂延迟后重新显示，确保组件完全重建
    setTimeout(() => {
      this.graphVisible = true;
    }, 50);

    promptAction.showToast({
      message: '已生成随机连通图',
      duration: 2000
    });
  }

  // 执行算法
  private executeAlgorithm(): void {
    if (!this.graph || this.cityNames.length === 0) {
      promptAction.showToast({
        message: '图数据未初始化',
        duration: 2000
      });
      return;
    }

    let result: AlgorithmResult;

    try {
      if (this.algorithmType === 'prim') {
        result = this.graph.prim(this.startNodeIndex);
      } else {
        result = this.graph.kruskal();
      }

      this.mstEdges = result.edges;
      this.totalCost = result.cost;
      this.showResultPanel = true;
      
      // 强制刷新组件 - 通过显隐控制强制重新渲染
      this.graphVisible = false;
      
      // 短暂延迟后重新显示，确保组件完全重建
      setTimeout(() => {
        this.graphVisible = true;
      }, 50);
      
      promptAction.showToast({
        message: `算法执行完成，总代价: ${this.totalCost}`,
        duration: 2000
      });
    } catch (error) {
      const errorMessage: string = error instanceof Error ? error.message : '执行算法时发生错误';
      promptAction.showToast({
        message: errorMessage,
        duration: 2000
      });
    }
  }

  // 保存图数据
  private async saveGraph(): Promise<void> {
    try {
      const success: boolean = await FileStorage.saveGraph(this.cityNames, this.adjacencyMatrix);
      if (success) {
        promptAction.showToast({
          message: '图数据已保存到本地存储',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '图数据保存失败',
          duration: 2000
        });
      }
    } catch (error) {
      const errorMessage: string = error instanceof Error ? error.message : '保存图数据时发生错误';
      promptAction.showToast({
        message: errorMessage,
        duration: 2000
      });
    }
  }

  // 加载图数据
  private async loadGraph(): Promise<void> {
    try {
      const data: GraphData | null = await FileStorage.loadGraph();
      if (data) {
        this.cityNames = data.cityNames || this.cityNames;
        this.adjacencyMatrix = data.matrix || this.adjacencyMatrix;
        this.graph.initialize(this.cityNames, this.adjacencyMatrix);
        this.updateAllEdges();
        this.showResultPanel = false;
        this.startNodeValue = '0';
        this.startNodeIndex = 0;
        
        // 强制刷新组件 - 通过显隐控制强制重新渲染
        this.graphVisible = false;
        
        // 短暂延迟后重新显示，确保组件完全重建
        setTimeout(() => {
          this.graphVisible = true;
        }, 50);

        promptAction.showToast({
          message: '图数据已从本地存储加载',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '未找到保存的图数据',
          duration: 2000
        });
      }
    } catch (error) {
      const errorMessage: string = error instanceof Error ? error.message : '加载图数据时发生错误';
      promptAction.showToast({
        message: errorMessage,
        duration: 2000
      });
    }
  }

  // 构建起始节点选择项数组
  private getStartNodeOptions(): SelectOption[] {
    const options: SelectOption[] = [];
    for (let i = 0; i < this.cityNames.length; i++) {
      options.push({
        value: i.toString(),
        label: this.cityNames[i]
      });
    }
    return options;
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Row() {
          Text('最小生成树算法演示')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10, bottom: 10 })

        // 控制面板
        Column() {
          Row() {
            // 算法选择
            Column() {
              Text('算法:')
                .fontSize(12)
                .margin({ bottom: 5 })

              Select(this.algorithmOptions)
                .value(this.algorithmType)
                .onSelect((index: number) => {
                  this.algorithmType = this.algorithmOptions[index].value;
                  this.showResultPanel = false;
                })
                .width(100)
            }
            .margin({ right: 10 })

            // 起始节点选择（仅Prim算法显示）
            if (this.algorithmType === 'prim') {
              Column() {
                Text('起始点:')
                  .fontSize(12)
                  .margin({ bottom: 5 })

                Select(this.getStartNodeOptions())
                  .value(this.startNodeValue)
                  .onSelect((index: number) => {
                    const options: SelectOption[] = this.getStartNodeOptions();
                    this.startNodeValue = options[index].value;
                    this.startNodeIndex = parseInt(this.startNodeValue);
                    this.showResultPanel = false;
                  })
                  .width(100)
              }
              .margin({ right: 10 })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 10 })

          // 操作按钮网格排布
          Row() {
            Button('随机生成图')
              .onClick(() => this.generateRandomGraph())
              .margin({ right: 10 })
              .backgroundColor('#52C41A')
              .fontColor('#FFFFFF')
              .fontSize(14)
              .width(160)
              .height(40)

            Button('执行')
              .onClick(() => this.executeAlgorithm())
              .margin({ right: 10 })
              .backgroundColor('#1890FF')
              .fontColor('#FFFFFF')
              .fontSize(14)
              .width(80)
              .height(40)

            Button('保存')
              .onClick(() => this.saveGraph())
              .margin({ right: 10 })
              .backgroundColor('#FAAD14')
              .fontColor('#FFFFFF')
              .fontSize(14)
              .width(80)
              .height(40)

            Button('加载')
              .onClick(() => this.loadGraph())
              .backgroundColor('#722ED1')
              .fontColor('#FFFFFF')
              .fontSize(14)
              .width(80)
              .height(40)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .margin({ top: 10, bottom: 10 })
        .padding(10)

        // 主要内容区域 - 上下排布
        Column() {
          // 矩阵编辑器
          Column() {
            Text('邻接矩阵:')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 10 })
              .fontColor('#1890FF')

            // 使用MatrixEditor组件
            MatrixEditor({
              cityNames: this.cityNames,
              matrix: this.adjacencyMatrix,
              onChange: (matrix: number[][]) => this.handleMatrixChange(matrix)
            })
              .key('matrix-' + this.refreshCounter)
              .height(250)
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 图形可视化
          if (this.graphVisible) {
            Column() {
              Text('图可视化:')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 10 })
                .fontColor('#1890FF')

              // 使用GraphVisualizer组件
              GraphVisualizer({
                cityNames: this.cityNames,
                allEdges: this.allEdges,
                mstEdges: this.showResultPanel ? this.mstEdges : []
              })
                .key(`graph-${this.refreshCounter}-${this.cityNames.length}-${this.allEdges.length}`)
                .height(350)
            }
            .width('100%')
          } else {
            // 显示占位符以保持布局
            Column() {
              Text('图可视化:')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 10 })
                .fontColor('#1890FF')
              
              Blank()
                .height(350)
            }
            .width('100%')
          }
        }
        .width('100%')

        // 结果面板
        if (this.showResultPanel) {
          Column() {
            Text('最小生成树结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
              .fontColor('#1890FF')

            // 边列表
            ForEach(this.mstEdges, (edge: Edge, index: number) => {
              Row() {
                Text(`${this.cityNames[edge.from]} → ${this.cityNames[edge.to]}`)
                  .fontSize(14)
                  .layoutWeight(1)
                Text(`权重: ${edge.weight}`)
                  .fontSize(14)
                  .fontColor('#52C41A')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding({ left: 10, right: 10, top: 10, bottom: 10 })
              .backgroundColor('#FFFFFF')
              .borderRadius(6)
              .margin({ bottom: 6 })
              .shadow({ radius: 4, color: '#0000001F', offsetX: 1, offsetY: 1 })
            })

            Divider()
              .strokeWidth(1)
              .color('#E8E8E8')
              .margin({ top: 10, bottom: 10 })

            Row() {
              Text('总代价:')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
              Text(this.totalCost.toString())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FA541C')
                .margin({ left: 10 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding({ left: 15, right: 15, top: 15, bottom: 15 })
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .margin({ top: 10, bottom: 20 })
          .shadow({ radius: 6, color: '#00000029', offsetX: 2, offsetY: 2 })
        }
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')
    }
    .scrollable(ScrollDirection.Vertical)
  }
}