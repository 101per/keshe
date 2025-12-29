/**
 * 应用主入口，使用Tabs实现底部导航
 */
import {AlgorithmDemo} from './AlgorithmDemo';
import { CitiesMap } from './CitiesMap';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Column() {
      // 页面内容区域
      Stack() {
        // 算法演示页面 (Index 0)
        if (this.currentIndex === 0) {
          AlgorithmDemo()
        }
        
        // 真实地图页面 (Index 1)
        if (this.currentIndex === 1) {
          CitiesMap()
        }
      }
      .layoutWeight(1)

      // 自定义底部标签栏
      this.BottomTabBar()
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  BottomTabBar() {
    Column() {
      Row() {
        // 算法演示 tab
        Column() {
          Image(this.currentIndex === 0 ? $r('app.media.icon_algorithm2') : $r('app.media.icon_algorithm1'))
            .width(24)
            .height(24)
            .scale({ x: this.currentIndex === 0 ? 1.2 : 1.0, y: this.currentIndex === 0 ? 1.2 : 1.0 })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
            .margin({ bottom: 8 })

          Text('算法演示')
            .fontColor(this.currentIndex === 0 ? '#007DFF' : '#999999')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
        }
        .onClick(() => {
          this.currentIndex = 0;
        })
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .height('100%')

        // 真实地图 tab
        Column() {
          Image(this.currentIndex === 1 ? $r('app.media.icon_map2') : $r('app.media.icon_map1'))
            .width(24)
            .height(24)
            .scale({ x: this.currentIndex === 1 ? 1.2 : 1.0, y: this.currentIndex === 1 ? 1.2 : 1.0 })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
            .margin({ bottom: 8 })

          Text('城市地图')
            .fontColor(this.currentIndex === 1 ? '#007DFF' : '#999999')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
        }
        .onClick(() => {
          this.currentIndex = 1;
        })
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .height('100%')
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding({ top: 10, bottom: 10, left: 20, right: 20 })
      .margin({ bottom: 20 })
      .height(60)
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .padding({ left: 16, right: 16 })
  }
}