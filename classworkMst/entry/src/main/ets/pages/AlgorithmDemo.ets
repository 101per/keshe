// AlgorithmDemo.ets 完整代码

import { MatrixEditor } from '../components/MatrixEditor';
import { GraphVisualizer } from '../components/GraphVisualizer';
import { Graph } from '../model/Graph';
import { CommonUtils } from '../utils/CommonUtils';
import { FileUtils } from '../utils/FileUtils';
import promptAction from '@ohos.promptAction';
import { common } from '@kit.AbilityKit';

interface Edge { from: number; to: number; weight: number; }
interface SelectOption { value: string; label: string; }
interface MenuOption { value: string; action: () => void; }

@Component
export struct AlgorithmDemo {
  // --- 状态管理 ---
  @State refreshKey: number = 0;
  @State cityNames: string[] = this.initializeCityNames();
  @State adjacencyMatrix: number[][] = [];
  @State algorithmType: string = 'prim';
  @State startNodeIndex: number = 0;
  @State mstEdges: Edge[] = [];
  @State totalCost: number = 0;
  @State showResultPanel: boolean = false;
  @State allEdges: Edge[] = [];
  @State graphVisible: boolean = true;
  @State isAnimating: boolean = false;
  @State currentStep: number = 0;
  @State animationSteps: Edge[] = [];
  @State importFileName: string = '';
  @State savedFiles: string[] = [];

  private graph: Graph = new Graph();
  private algorithmOptions: SelectOption[] = [
    { value: 'prim', label: 'Prim算法' },
    { value: 'kruskal', label: 'Kruskal算法' }
  ];

  private initializeCityNames(): string[] {
    const names: string[] = [];
    for (let i = 1; i <= 8; i++) names.push(`城市${i}`);
    return names;
  }

  aboutToAppear(): void {
    this.refreshFileList();
    this.initializeGraph();
  }

  private refreshFileList(): void {
    const context = getContext(this) as common.UIAbilityContext;
    this.savedFiles = FileUtils.listGraphFiles(context);
  }

  private initializeGraph(): void {
    const matrix = CommonUtils.generateRandomConnectedGraph(this.cityNames.length);
    this.adjacencyMatrix = matrix;
    this.graph.initialize(this.cityNames, matrix);
    this.updateAllEdges();
    this.resetMSTStates();
    this.triggerGraphRefresh();
  }

  private updateAllEdges(): void {
    const edges: Edge[] = [];
    for (let i = 0; i < this.cityNames.length; i++) {
      for (let j = i + 1; j < this.cityNames.length; j++) {
        const weight = this.adjacencyMatrix[i][j];
        if (weight > 0 && weight !== Infinity) {
          edges.push({ from: i, to: j, weight: weight });
        }
      }
    }
    this.allEdges = edges;
  }

  private resetMSTStates(): void {
    this.showResultPanel = false;
    this.isAnimating = false;
    this.currentStep = 0;
    this.mstEdges = [];
  }

  private triggerGraphRefresh(): void {
    this.refreshKey++;
    this.graphVisible = false;
    setTimeout(() => { this.graphVisible = true; }, 20);
  }

  private executeAlgorithm(): void {
    try {
      let result = this.algorithmType === 'prim' ?
        this.graph.prim(this.startNodeIndex) : this.graph.kruskal();
      this.mstEdges = result.edges;
      this.totalCost = result.cost;
      this.animationSteps = [...result.edges];
      this.showResultPanel = true;
      this.isAnimating = false;
      this.currentStep = 0;
      this.triggerGraphRefresh();
      promptAction.showToast({ message: `计算完成！` });
    } catch (e) {
      promptAction.showToast({ message: '执行失败' });
    }
  }

  private getFileMenuOptions(): MenuOption[] {
    if (this.savedFiles.length === 0) return [{ value: '暂无文件', action: () => {} }];
    return this.savedFiles.map(name => ({
      value: name,
      action: () => { this.importFileName = name; }
    } as MenuOption));
  }

  // --- 新增：删除功能 ---
  private async deleteGraph() {
    if (!this.importFileName) {
      promptAction.showToast({ message: '请先选择文件名' });
      return;
    }

    AlertDialog.show({
      title: '确认删除',
      message: `确定要永久删除文件 "${this.importFileName}" 吗？`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: () => {
          const context = getContext(this) as common.UIAbilityContext;
          if (FileUtils.deleteGraphFile(context, this.importFileName)) {
            promptAction.showToast({ message: '已删除' });
            this.importFileName = '';
            this.refreshFileList();
          }
        }
      }
    });
  }

  build() {
    Scroll() {
      Column() {
        Text('MST 算法演示系统').fontSize(24).fontWeight(FontWeight.Bold).margin(15).fontColor('#1890FF')

        // --- 第一部分：算法与文件控制栏 ---
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            Select(this.algorithmOptions).value(this.algorithmType)
              .onSelect((idx) => {
                this.algorithmType = this.algorithmOptions[idx].value;
                this.resetMSTStates();
              }).width('40%')

            if (this.algorithmType === 'prim') {
              Select(this.cityNames.map((n, i) => ({ value: i.toString(), label: n } as SelectOption)))
                .value(this.cityNames[this.startNodeIndex])
                .onSelect((idx) => {
                  this.startNodeIndex = idx;
                  this.resetMSTStates();
                }).width('50%')
            }
          }.width('100%')

          Row({ space: 10 }) {
            Button('随机生成').onClick(() => this.initializeGraph()).backgroundColor('#52C41A').layoutWeight(1)
            Button('执行算法').onClick(() => this.executeAlgorithm()).backgroundColor('#1890FF').layoutWeight(1)
          }.width('100%')

          // 文件操作行
          Row({ space: 5 }) {
            Stack({ alignContent: Alignment.End }) {
              TextInput({ text: this.importFileName, placeholder: '文件名' })
                .onChange(v => this.importFileName = v)
                .padding({ right: 35 })
              Button('▼').bindMenu(this.getFileMenuOptions()).backgroundColor(Color.Transparent).fontColor(Color.Gray)
            }.layoutWeight(1)

            Button('保存').onClick(() => this.saveGraph()).backgroundColor('#722ED1').fontSize(14)
            Button('导入').onClick(() => this.loadGraph()).backgroundColor('#FA8C16').fontSize(14)
            // 新增红色删除按钮
            Button('删除').onClick(() => this.deleteGraph()).backgroundColor('#F5222D').fontSize(14)
          }.width('100%')
        }
        .padding(15).backgroundColor('#F5F7FA').borderRadius(12).margin({ bottom: 20 })

        // --- 第二部分：矩阵编辑 ---
        Text('邻接矩阵').fontSize(16).fontWeight(FontWeight.Medium).alignSelf(ItemAlign.Start).margin(5)
        MatrixEditor({
          cityNames: this.cityNames,
          matrix: this.adjacencyMatrix,
          onChange: (m) => {
            this.adjacencyMatrix = m;
            this.graph.initialize(this.cityNames, m);
            this.updateAllEdges();
            this.resetMSTStates();
            this.triggerGraphRefresh();
          }
        }).height(320).margin({ bottom: 20 })

        // --- 第三部分：可视化演示 ---
        if (this.graphVisible) {
          Column() {
            Row({ space: 10 }) {
              Button('开始演示')
                .onClick(() => {
                  if (this.mstEdges.length === 0) {
                    promptAction.showToast({ message: '请先点击“执行算法”' });
                    return;
                  }
                  this.isAnimating = true;
                  this.currentStep = 0;
                  this.refreshKey++;
                })
                .backgroundColor(this.mstEdges.length > 0 ? '#1890FF' : '#A0CFFF').height(35)

              Button('下一步')
                .onClick(() => {
                  if (this.currentStep < this.animationSteps.length) {
                    this.currentStep++;
                    this.refreshKey++;
                  } else {
                    promptAction.showToast({ message: '演示已完成' });
                  }
                })
                .enabled(this.isAnimating && this.currentStep < this.animationSteps.length).height(35)

              Button('重置')
                .onClick(() => {
                  this.isAnimating = false;
                  this.currentStep = 0;
                  this.refreshKey++;
                })
                .enabled(this.isAnimating).backgroundColor(this.isAnimating ? Color.Gray : '#DCDFE6').height(35)

              if (this.isAnimating) {
                Text(`${this.currentStep}/${this.animationSteps.length}`)
                  .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1890FF')
              }
            }.margin({ bottom: 10 })

            GraphVisualizer({
              cityNames: this.cityNames,
              allEdges: this.allEdges,
              mstEdges: this.mstEdges,
              isAnimating: this.isAnimating,
              currentStep: this.currentStep
            }).key(`graph_v_${this.refreshKey}_${this.currentStep}`)
              .height(400).width('100%').backgroundColor('#F9F9F9').borderRadius(10)
          }
        }

        // --- 第四部分：结果详情面板 ---
        if (this.showResultPanel) {
          Column() {
            Text('MST 执行结果').fontSize(18).fontWeight(FontWeight.Bold).margin(10)
            ForEach(this.mstEdges, (edge: Edge, index: number) => {
              Row() {
                Text(`步骤 ${index + 1}: ${this.cityNames[edge.from]} ↔ ${this.cityNames[edge.to]}`).layoutWeight(1)
                Text(`权重: ${edge.weight}`).fontColor('#52C41A').fontWeight(FontWeight.Bold)
              }.width('100%').padding(10).border({ width: { bottom: 1 }, color: '#EEE' })
            })
            Text(`总路径代价: ${this.totalCost}`).fontSize(18).fontColor('#FA541C').fontWeight(FontWeight.Bold).margin(15)
          }
          .width('100%').backgroundColor('#F0F9FF').borderRadius(10).margin({ top: 20, bottom: 40 })
        }
      }
      .padding(15)
    }
  }

  // --- 原有文件保存/导入逻辑 ---
  private async saveGraph() {
    const context = getContext(this) as common.UIAbilityContext;
    const name = this.importFileName || `graph_${Date.now()}.json`;
    const success = await FileUtils.saveGraphToFile(context, this.graph, name);
    if (success) {
      this.refreshFileList();
      promptAction.showToast({ message: '保存成功: ' + name });
    }
  }

  private async loadGraph() {
    const context = getContext(this) as common.UIAbilityContext;
    const data = await FileUtils.loadGraphFromFile(context, this.importFileName);
    if (data) {
      this.cityNames = [...data.cityNames];
      this.adjacencyMatrix = data.matrix.map(row => [...row]);
      this.graph.initialize(this.cityNames, this.adjacencyMatrix);
      this.updateAllEdges();
      this.resetMSTStates();
      this.triggerGraphRefresh();
      promptAction.showToast({ message: '数据导入成功' });
    }
  }
}