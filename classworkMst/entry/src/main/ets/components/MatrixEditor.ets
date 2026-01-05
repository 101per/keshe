/**
 * 可编辑邻接矩阵表格组件
 */
import { CommonUtils } from '../utils/CommonUtils';

// 定义矩阵变化回调类型
type MatrixChangeCallback = (matrix: number[][]) => void;

@Component
export struct MatrixEditor {
  // 使用 @Prop 装饰器，这样父组件的数据变化会自动同步
  @Prop cityNames: string[] = [];
  @Prop matrix: number[][] = [];
  // onChange 不需要装饰器，它是回调函数
  onChange: MatrixChangeCallback = () => {};

  // 添加一个内部状态来触发强制更新
  @State refreshKey: number = 0;

  aboutToUpdate() {
    // 当父组件传递的 props 变化时，这里会被调用
    this.refreshKey++;
  }

  build() {
    Scroll() {
      Column() {
        // 表头行
        Row() {
          Blank()
            .width(42)
            .height(32)

          ForEach(this.cityNames, (cityName: string, index: number) => {
            Text(cityName && cityName.length > 3 ? cityName.substring(0, 3) : (cityName || ''))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .width(46)
              .height(32)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(3)
              .margin(1)

          })
        }
        .width('100%')

        // 矩阵数据行
        ForEach(this.matrix, (row: number[], rowIndex: number) => {
          Row() {
            // 行标题
            Text(this.cityNames[rowIndex] && this.cityNames[rowIndex].length > 3 ?
              this.cityNames[rowIndex].substring(0, 3) : (this.cityNames[rowIndex] || ''))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .width(40)
              .height(32)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(3)
              .margin(1)

            // 数据单元格
            ForEach(row, (cell: number, colIndex: number) => {
              // 为每个输入框添加唯一的 key，确保数据变化时重新渲染
              TextInput({
                placeholder: '-',
                text: rowIndex === colIndex ? '0' : CommonUtils.formatNumber(cell)
              })
                .key(`cell-${rowIndex}-${colIndex}-${this.refreshKey}`) // 添加 key 确保更新
                .enabled(rowIndex !== colIndex)
                .width(45)
                .height(32)
                .fontSize(10)
                .textAlign(TextAlign.Center)
                .backgroundColor('#FFFFFF')
                .margin(1)
                .border({
                  width: 1,
                  color: '#E0E0E0',
                  radius: 3
                })
                .onChange((value: string) => {
                  if (!this.matrix || rowIndex >= this.matrix.length || colIndex >= this.matrix[rowIndex].length) {
                    return;
                  }

                  let numValue: number;
                  // 核心：识别无穷大符号和空输入
                  if (value === '' || value === '-' || value === '∞') {
                    numValue = Infinity;
                  } else {
                    numValue = Number(value);
                  }

                  if (!isNaN(numValue)) { // 确保是合法数字或 Infinity
                    const newMatrix = this.matrix.map(r => [...r]);
                    newMatrix[rowIndex][colIndex] = numValue;
                    newMatrix[colIndex][rowIndex] = numValue; // 保持对称

                    if (this.onChange) {
                      this.onChange(newMatrix);
                    }
                  }
                })
            })
          }
          .width('100%')
        })
      }
      .padding({ left: 5, right: 5 })
      .width('100%')
    }
    .scrollable(ScrollDirection.Horizontal | ScrollDirection.Vertical)
  }
}