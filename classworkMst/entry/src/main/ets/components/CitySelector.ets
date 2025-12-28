/**
 * 真实城市多选列表组件（带搜索过滤）
 */
import { CityData, City } from '../model/CityData';

@Component
export struct CitySelector {
  // 所有城市
  private allCities: City[] = CityData.CITIES;
  // 过滤后的城市
  private filteredCities: City[] = CityData.CITIES;
  // 搜索关键字
  private searchKeyword: string = '';
  // 已选中的城市索引
  private selectedIndices: number[] = [];
  // 选择变化回调
  private onSelectionChange: (indices: number[]) => void = () => {};

  // 设置已选中的城市索引
  setSelectedIndices(indices: number[]): void {
    this.selectedIndices = [...indices];
  }

  // 设置选择变化回调
  setOnSelectionChange(callback: (indices: number[]) => void): void {
    this.onSelectionChange = callback;
  }

  // 处理搜索关键字变化
  private handleSearchChange(value: string): void {
    this.searchKeyword = value;
    this.filterCities();
  }

  // 过滤城市
  private filterCities(): void {
    if (this.searchKeyword.trim() === '') {
      this.filteredCities = [...this.allCities];
    } else {
      this.filteredCities = this.allCities.filter(city => 
        city.name.includes(this.searchKeyword.trim())
      );
    }
  }

  // 处理城市选择变化
  private handleCityToggle(cityIndex: number, isSelected: boolean): void {
    if (isSelected) {
      // 添加到选中列表
      if (!this.selectedIndices.includes(cityIndex)) {
        this.selectedIndices.push(cityIndex);
      }
    } else {
      // 从选中列表移除
      const index = this.selectedIndices.indexOf(cityIndex);
      if (index !== -1) {
        this.selectedIndices.splice(index, 1);
      }
    }
    
    // 触发选择变化回调
    this.onSelectionChange([...this.selectedIndices]);
  }

  // 获取城市在原始列表中的索引
  private getOriginalIndex(city: City): number {
    return this.allCities.findIndex(c => c.name === city.name);
  }

  build() {
    Column() {
      // 搜索框
      TextInput({
        placeholder: '搜索城市...'
      })
      .width('90%')
      .height(40)
      .fontSize(14)
      .margin({ top: 10 })
      .onChange((value: string) => {
        this.handleSearchChange(value);
      })

      // 城市列表
      Scroll() {
        Column() {
          ForEach(this.filteredCities, (city: City, index: number) => {
            Column() {
              Row() {
                Toggle({ type: ToggleType.Checkbox, isOn: this.selectedIndices.includes(this.getOriginalIndex(city)) })
                  .onChange((isChecked: boolean) => {
                    const originalIndex = this.getOriginalIndex(city);
                    this.handleCityToggle(originalIndex, isChecked);
                  })
                
                Text(city.name)
                  .fontSize(16)
                  .layoutWeight(1)
                  .margin({ left: 10 })
                
                Text(`(${city.latitude.toFixed(2)}, ${city.longitude.toFixed(2)})`)
                  .fontSize(12)
                  .fontColor('#888888')
              }
              .width('100%')
              .padding({ left: 20, right: 20 })
              
              Divider()
                .margin({ top: 5, bottom: 5 })
            }
          })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 10 })
    }
  }
}