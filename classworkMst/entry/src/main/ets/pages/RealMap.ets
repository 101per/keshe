import http from '@ohos.net.http';
import { AlgorithmPanel } from '../componentsPPlus/AlgorithmPanel';
import { GraphEdge, NodeInfo } from '../model/GraphPPlus';
import { Projection } from '../utils/Projection';

// ==========================================
// 1. 数据模型定义
// ==========================================
interface ProvinceDetail extends NodeInfo {
  zoom: number;
  cities: NodeInfo[];
}

// ==========================================
// 2. 全国数据源
// ==========================================
const PROVINCE_DATA: ProvinceDetail[] = [
  { name: '全国概览', lng: 105.000, lat: 35.000, zoom: 4, cities: [] }, // 0号索引特殊处理
  { name: '北京', lng: 116.407, lat: 39.904, zoom: 10, cities: [
    { name: '东城', lng: 116.416, lat: 39.928 }, { name: '西城', lng: 116.365, lat: 39.906 },
    { name: '朝阳', lng: 116.443, lat: 39.921 }, { name: '丰台', lng: 116.287, lat: 39.858 },
    { name: '石景山', lng: 116.222, lat: 39.905 }, { name: '海淀', lng: 116.298, lat: 39.959 },
    { name: '门头沟', lng: 116.101, lat: 39.940 }, { name: '房山', lng: 116.142, lat: 39.747 },
    { name: '通州', lng: 116.657, lat: 39.909 }, { name: '顺义', lng: 116.654, lat: 40.130 },
    { name: '昌平', lng: 116.231, lat: 40.220 }, { name: '大兴', lng: 116.341, lat: 39.726 }
  ]},
  { name: '上海', lng: 121.473, lat: 31.230, zoom: 10, cities: [
    { name: '黄浦', lng: 121.484, lat: 31.231 }, { name: '徐汇', lng: 121.436, lat: 31.188 },
    { name: '长宁', lng: 121.424, lat: 31.220 }, { name: '静安', lng: 121.447, lat: 31.227 },
    { name: '普陀', lng: 121.397, lat: 31.249 }, { name: '虹口', lng: 121.481, lat: 31.277 },
    { name: '杨浦', lng: 121.526, lat: 31.259 }, { name: '闵行', lng: 121.381, lat: 31.112 },
    { name: '宝山', lng: 121.489, lat: 31.405 }, { name: '嘉定', lng: 121.265, lat: 31.375 },
    { name: '浦东', lng: 121.544, lat: 31.221 }, { name: '松江', lng: 121.227, lat: 31.032 }
  ]},
  { name: '天津', lng: 117.200, lat: 39.084, zoom: 9, cities: [
    { name: '和平', lng: 117.214, lat: 39.117 }, { name: '河东', lng: 117.225, lat: 39.120 },
    { name: '河西', lng: 117.223, lat: 39.109 }, { name: '南开', lng: 117.150, lat: 39.138 },
    { name: '河北', lng: 117.196, lat: 39.148 }, { name: '红桥', lng: 117.151, lat: 39.167 },
    { name: '滨海新区', lng: 117.654, lat: 39.032 }, { name: '东丽', lng: 117.313, lat: 39.086 },
    { name: '西青', lng: 117.009, lat: 39.141 }, { name: '津南', lng: 117.385, lat: 38.991 }
  ]},
  { name: '重庆', lng: 106.551, lat: 29.563, zoom: 8, cities: [
    { name: '渝中', lng: 106.569, lat: 29.552 }, { name: '大渡口', lng: 106.482, lat: 29.484 },
    { name: '江北', lng: 106.574, lat: 29.606 }, { name: '沙坪坝', lng: 106.468, lat: 29.541 },
    { name: '九龙坡', lng: 106.511, lat: 29.501 }, { name: '南岸', lng: 106.563, lat: 29.523 },
    { name: '北碚', lng: 106.437, lat: 29.805 }, { name: '渝北', lng: 106.511, lat: 29.672 },
    { name: '巴南', lng: 106.540, lat: 29.395 }, { name: '万州', lng: 108.408, lat: 30.807 }
  ]},
  { name: '广东', lng: 113.264, lat: 23.129, zoom: 7, cities: [
    { name: '广州', lng: 113.264, lat: 23.129 }, { name: '深圳', lng: 114.057, lat: 22.543 },
    { name: '珠海', lng: 113.576, lat: 22.270 }, { name: '汕头', lng: 116.681, lat: 23.354 },
    { name: '佛山', lng: 113.121, lat: 23.021 }, { name: '韶关', lng: 113.597, lat: 24.810 },
    { name: '湛江', lng: 110.359, lat: 21.270 }, { name: '肇庆', lng: 112.465, lat: 23.047 },
    { name: '江门', lng: 113.081, lat: 22.578 }, { name: '茂名', lng: 110.925, lat: 21.662 },
    { name: '惠州', lng: 114.416, lat: 23.111 }, { name: '梅州', lng: 116.122, lat: 24.288 },
    { name: '汕尾', lng: 115.375, lat: 22.786 }, { name: '河源', lng: 114.700, lat: 23.743 },
    { name: '阳江', lng: 111.982, lat: 21.858 }, { name: '清远', lng: 113.019, lat: 23.681 },
    { name: '东莞', lng: 113.751, lat: 23.020 }, { name: '中山', lng: 113.392, lat: 22.517 },
    { name: '潮州', lng: 116.622, lat: 23.656 }, { name: '揭阳', lng: 116.372, lat: 23.549 },
    { name: '云浮', lng: 112.044, lat: 22.915 }
  ]},
  { name: '江苏', lng: 118.796, lat: 32.058, zoom: 7, cities: [
    { name: '南京', lng: 118.796, lat: 32.058 }, { name: '无锡', lng: 120.311, lat: 31.491 },
    { name: '徐州', lng: 117.284, lat: 34.261 }, { name: '常州', lng: 119.973, lat: 31.810 },
    { name: '苏州', lng: 120.585, lat: 31.298 }, { name: '南通', lng: 120.894, lat: 31.980 },
    { name: '连云港', lng: 119.221, lat: 34.596 }, { name: '淮安', lng: 119.015, lat: 33.610 },
    { name: '盐城', lng: 120.163, lat: 33.347 }, { name: '扬州', lng: 119.412, lat: 32.394 },
    { name: '镇江', lng: 119.452, lat: 32.204 }, { name: '泰州', lng: 119.929, lat: 32.455 },
    { name: '宿迁', lng: 118.275, lat: 33.963 }
  ]},
  { name: '浙江', lng: 120.155, lat: 30.274, zoom: 7, cities: [
    { name: '杭州', lng: 120.155, lat: 30.274 }, { name: '宁波', lng: 121.543, lat: 29.868 },
    { name: '温州', lng: 120.699, lat: 27.994 }, { name: '嘉兴', lng: 120.755, lat: 30.753 },
    { name: '湖州', lng: 120.086, lat: 30.894 }, { name: '绍兴', lng: 120.580, lat: 30.030 },
    { name: '金华', lng: 119.647, lat: 29.079 }, { name: '衢州', lng: 118.859, lat: 28.970 },
    { name: '舟山', lng: 122.207, lat: 29.985 }, { name: '台州', lng: 121.420, lat: 28.656 },
    { name: '丽水', lng: 119.921, lat: 28.451 }
  ]},
  { name: '四川', lng: 104.066, lat: 30.572, zoom: 6, cities: [
    { name: '成都', lng: 104.066, lat: 30.572 }, { name: '自贡', lng: 104.778, lat: 29.339 },
    { name: '攀枝花', lng: 101.718, lat: 26.582 }, { name: '泸州', lng: 105.442, lat: 28.871 },
    { name: '德阳', lng: 104.397, lat: 31.126 }, { name: '绵阳', lng: 104.732, lat: 31.460 },
    { name: '广元', lng: 105.843, lat: 32.435 }, { name: '遂宁', lng: 105.592, lat: 30.532 },
    { name: '内江', lng: 105.058, lat: 29.580 }, { name: '乐山', lng: 103.765, lat: 29.552 },
    { name: '南充', lng: 106.110, lat: 30.837 }, { name: '眉山', lng: 103.848, lat: 30.076 },
    { name: '宜宾', lng: 104.643, lat: 28.752 }, { name: '广安', lng: 106.633, lat: 30.456 },
    { name: '达州', lng: 107.502, lat: 31.209 }, { name: '雅安', lng: 103.042, lat: 29.980 },
    { name: '巴中', lng: 106.753, lat: 31.858 }
  ]},
  { name: '湖北', lng: 114.305, lat: 30.592, zoom: 7, cities: [
    { name: '武汉', lng: 114.305, lat: 30.592 }, { name: '黄石', lng: 115.038, lat: 30.198 },
    { name: '十堰', lng: 110.799, lat: 32.629 }, { name: '宜昌', lng: 111.286, lat: 30.691 },
    { name: '襄阳', lng: 112.122, lat: 32.008 }, { name: '鄂州', lng: 114.894, lat: 30.391 },
    { name: '荆门', lng: 112.199, lat: 31.035 }, { name: '孝感', lng: 113.955, lat: 30.920 },
    { name: '荆州', lng: 112.239, lat: 30.335 }, { name: '黄冈', lng: 114.872, lat: 30.453 },
    { name: '咸宁', lng: 114.322, lat: 29.841 }, { name: '随州', lng: 113.382, lat: 31.690 },
    { name: '恩施', lng: 109.486, lat: 30.272 }
  ]},
  { name: '福建', lng: 119.296, lat: 26.074, zoom: 7, cities: [
    { name: '福州', lng: 119.296, lat: 26.074 }, { name: '厦门', lng: 118.089, lat: 24.479 },
    { name: '莆田', lng: 119.007, lat: 25.454 }, { name: '三明', lng: 117.635, lat: 26.263 },
    { name: '泉州', lng: 118.675, lat: 24.874 }, { name: '漳州', lng: 117.647, lat: 24.513 },
    { name: '南平', lng: 118.177, lat: 26.641 }, { name: '龙岩', lng: 117.017, lat: 25.075 },
    { name: '宁德', lng: 119.547, lat: 26.665 }
  ]},
  { name: '湖南', lng: 112.938, lat: 28.228, zoom: 7, cities: [
    { name: '长沙', lng: 112.938, lat: 28.228 }, { name: '株洲', lng: 113.133, lat: 27.827 },
    { name: '湘潭', lng: 112.944, lat: 27.829 }, { name: '衡阳', lng: 112.571, lat: 26.893 },
    { name: '邵阳', lng: 111.469, lat: 27.237 }, { name: '岳阳', lng: 113.132, lat: 29.370 },
    { name: '常德', lng: 111.691, lat: 29.040 }, { name: '张家界', lng: 110.479, lat: 29.117 },
    { name: '益阳', lng: 112.355, lat: 28.553 }, { name: '郴州', lng: 113.014, lat: 25.770 },
    { name: '永州', lng: 111.608, lat: 26.434 }, { name: '怀化', lng: 109.998, lat: 27.554 },
    { name: '娄底', lng: 112.008, lat: 27.728 }
  ]},
  { name: '山东', lng: 117.020, lat: 36.668, zoom: 7, cities: [
    { name: '济南', lng: 117.020, lat: 36.668 }, { name: '青岛', lng: 120.382, lat: 36.067 },
    { name: '淄博', lng: 118.037, lat: 36.813 }, { name: '枣庄', lng: 117.323, lat: 34.810 },
    { name: '东营', lng: 118.674, lat: 37.434 }, { name: '烟台', lng: 121.447, lat: 37.463 },
    { name: '潍坊', lng: 119.161, lat: 36.706 }, { name: '济宁', lng: 116.587, lat: 35.414 },
    { name: '泰安', lng: 117.087, lat: 36.200 }, { name: '威海', lng: 122.120, lat: 37.513 },
    { name: '日照', lng: 119.526, lat: 35.416 }, { name: '临沂', lng: 118.356, lat: 35.103 },
    { name: '德州', lng: 116.357, lat: 37.434 }, { name: '聊城', lng: 115.985, lat: 36.456 },
    { name: '滨州', lng: 117.970, lat: 37.383 }, { name: '菏泽', lng: 115.480, lat: 35.233 }
  ]},
  { name: '河南', lng: 113.625, lat: 34.746, zoom: 7, cities: [
    { name: '郑州', lng: 113.625, lat: 34.746 }, { name: '开封', lng: 114.300, lat: 34.797 },
    { name: '洛阳', lng: 112.453, lat: 34.618 }, { name: '平顶山', lng: 113.192, lat: 33.766 },
    { name: '安阳', lng: 114.392, lat: 36.097 }, { name: '鹤壁', lng: 114.297, lat: 35.748 },
    { name: '新乡', lng: 113.926, lat: 35.303 }, { name: '焦作', lng: 113.241, lat: 35.215 },
    { name: '濮阳', lng: 115.029, lat: 35.761 }, { name: '许昌', lng: 113.852, lat: 34.035 },
    { name: '漯河', lng: 114.016, lat: 33.586 }, { name: '三门峡', lng: 111.200, lat: 34.770 },
    { name: '南阳', lng: 112.528, lat: 32.990 }, { name: '商丘', lng: 115.656, lat: 34.414 },
    { name: '信阳', lng: 114.091, lat: 32.147 }, { name: '周口', lng: 114.697, lat: 33.625 },
    { name: '驻马店', lng: 114.029, lat: 32.980 }
  ]},
  { name: '河北', lng: 114.471, lat: 38.042, zoom: 7, cities: [
    { name: '石家庄', lng: 114.514, lat: 38.042 }, { name: '唐山', lng: 118.180, lat: 39.630 },
    { name: '秦皇岛', lng: 119.598, lat: 39.940 }, { name: '邯郸', lng: 114.477, lat: 36.625 },
    { name: '邢台', lng: 114.495, lat: 37.070 }, { name: '保定', lng: 115.464, lat: 38.873 },
    { name: '张家口', lng: 114.885, lat: 40.768 }, { name: '承德', lng: 117.968, lat: 40.951 },
    { name: '沧州', lng: 116.838, lat: 38.304 }, { name: '廊坊', lng: 116.683, lat: 39.538 },
    { name: '衡水', lng: 115.673, lat: 37.738 }
  ]},
  { name: '山西', lng: 112.562, lat: 37.870, zoom: 7, cities: [
    { name: '太原', lng: 112.562, lat: 37.870 }, { name: '大同', lng: 113.300, lat: 40.076 },
    { name: '阳泉', lng: 113.580, lat: 37.857 }, { name: '长治', lng: 113.116, lat: 36.195 },
    { name: '晋城', lng: 112.851, lat: 35.497 }, { name: '朔州', lng: 112.433, lat: 39.331 },
    { name: '晋中', lng: 112.752, lat: 37.687 }, { name: '运城', lng: 111.006, lat: 35.026 },
    { name: '忻州', lng: 112.734, lat: 38.416 }, { name: '临汾', lng: 111.519, lat: 36.088 },
    { name: '吕梁', lng: 111.144, lat: 37.518 }
  ]},
  { name: '陕西', lng: 108.939, lat: 34.341, zoom: 7, cities: [
    { name: '西安', lng: 108.939, lat: 34.341 }, { name: '铜川', lng: 109.089, lat: 35.088 },
    { name: '宝鸡', lng: 107.237, lat: 34.362 }, { name: '咸阳', lng: 108.709, lat: 34.329 },
    { name: '渭南', lng: 109.500, lat: 34.499 }, { name: '延安', lng: 109.489, lat: 36.585 },
    { name: '汉中', lng: 107.031, lat: 33.067 }, { name: '榆林', lng: 109.734, lat: 38.285 },
    { name: '安康', lng: 109.029, lat: 32.684 }, { name: '商洛', lng: 109.941, lat: 33.862 }
  ]},
  { name: '安徽', lng: 117.227, lat: 31.820, zoom: 7, cities: [
    { name: '合肥', lng: 117.227, lat: 31.820 }, { name: '芜湖', lng: 118.384, lat: 31.335 },
    { name: '蚌埠', lng: 117.389, lat: 32.916 }, { name: '淮南', lng: 116.999, lat: 32.624 },
    { name: '马鞍山', lng: 118.506, lat: 31.699 }, { name: '淮北', lng: 116.798, lat: 33.955 },
    { name: '铜陵', lng: 117.811, lat: 30.945 }, { name: '安庆', lng: 117.063, lat: 30.542 },
    { name: '黄山', lng: 118.337, lat: 29.714 }, { name: '滁州', lng: 118.316, lat: 32.303 },
    { name: '阜阳', lng: 115.814, lat: 32.890 }, { name: '宿州', lng: 116.984, lat: 33.633 },
    { name: '六安', lng: 116.507, lat: 31.752 }, { name: '亳州', lng: 115.778, lat: 33.844 }
  ]},
  { name: '江西', lng: 115.816, lat: 28.634, zoom: 7, cities: [
    { name: '南昌', lng: 115.816, lat: 28.634 }, { name: '景德镇', lng: 117.178, lat: 29.268 },
    { name: '萍乡', lng: 113.852, lat: 27.622 }, { name: '九江', lng: 116.001, lat: 29.705 },
    { name: '新余', lng: 114.917, lat: 27.817 }, { name: '鹰潭', lng: 117.068, lat: 28.274 },
    { name: '赣州', lng: 114.935, lat: 25.831 }, { name: '吉安', lng: 114.992, lat: 27.113 },
    { name: '宜春', lng: 114.416, lat: 27.815 }, { name: '抚州', lng: 116.358, lat: 27.983 },
    { name: '上饶', lng: 117.943, lat: 28.454 }
  ]},
  // --- 补充与扩充的详细数据 ---
  { name: '海南', lng: 109.798, lat: 19.044, zoom: 8, cities: [
    { name: '海口', lng: 110.329, lat: 20.031 }, { name: '三亚', lng: 109.511, lat: 18.252 },
    { name: '三沙', lng: 112.338, lat: 16.831 }, { name: '儋州', lng: 109.576, lat: 19.517 },
    { name: '文昌', lng: 110.753, lat: 19.612 }, { name: '琼海', lng: 110.474, lat: 19.258 },
    { name: '万宁', lng: 110.388, lat: 18.795 }, { name: '五指山', lng: 110.400, lat: 18.776 },
    { name: '东方', lng: 108.653, lat: 19.101 }, { name: '澄迈', lng: 110.007, lat: 19.738 }
  ]},
  { name: '云南', lng: 101.832, lat: 24.880, zoom: 6, cities: [
    { name: '昆明', lng: 102.832, lat: 24.880 }, { name: '曲靖', lng: 103.796, lat: 25.490 },
    { name: '玉溪', lng: 102.546, lat: 24.352 }, { name: '保山', lng: 99.161, lat: 25.111 },
    { name: '昭通', lng: 103.717, lat: 27.336 }, { name: '丽江', lng: 100.226, lat: 26.855 },
    { name: '普洱', lng: 100.966, lat: 22.785 }, { name: '临沧', lng: 100.086, lat: 23.886 },
    { name: '大理', lng: 100.225, lat: 25.591 }, { name: '西双版纳', lng: 100.797, lat: 22.001 },
    { name: '德宏', lng: 98.578, lat: 24.436 }, { name: '怒江', lng: 98.583, lat: 25.850 }
  ]},
  { name: '贵州', lng: 106.630, lat: 26.647, zoom: 7, cities: [
    { name: '贵阳', lng: 106.630, lat: 26.647 }, { name: '六盘水', lng: 104.830, lat: 26.592 },
    { name: '遵义', lng: 106.927, lat: 27.725 }, { name: '安顺', lng: 105.946, lat: 26.253 },
    { name: '毕节', lng: 104.825, lat: 27.301 }, { name: '铜仁', lng: 109.191, lat: 27.718 },
    { name: '黔西南', lng: 104.897, lat: 25.088 }, { name: '黔东南', lng: 107.977, lat: 26.583 },
    { name: '黔南', lng: 107.517, lat: 26.259 }
  ]},
  { name: '黑龙江', lng: 128.661, lat: 47.742, zoom: 6, cities: [
    { name: '哈尔滨', lng: 126.661, lat: 45.742 }, { name: '齐齐哈尔', lng: 123.918, lat: 47.354 },
    { name: '鸡西', lng: 130.969, lat: 45.295 }, { name: '鹤岗', lng: 130.297, lat: 47.349 },
    { name: '大庆', lng: 125.103, lat: 46.589 }, { name: '伊春', lng: 128.899, lat: 47.724 },
    { name: '佳木斯', lng: 130.363, lat: 46.806 }, { name: '牡丹江', lng: 129.633, lat: 44.551 },
    { name: '黑河', lng: 127.526, lat: 50.244 }, { name: '大兴安岭', lng: 124.711, lat: 52.335 },
    { name: '绥化', lng: 126.968, lat: 46.653 }
  ]},
  { name: '吉林', lng: 126.323, lat: 43.817, zoom: 6, cities: [
    { name: '长春', lng: 125.323, lat: 43.817 }, { name: '吉林', lng: 126.549, lat: 43.837 },
    { name: '四平', lng: 124.350, lat: 43.166 }, { name: '辽源', lng: 125.126, lat: 42.888 },
    { name: '通化', lng: 125.937, lat: 41.728 }, { name: '白山', lng: 126.420, lat: 41.938 },
    { name: '松原', lng: 124.825, lat: 45.141 }, { name: '白城', lng: 122.838, lat: 45.619 },
    { name: '延边', lng: 129.508, lat: 42.891 }
  ]},
  { name: '辽宁', lng: 122.431, lat: 41.805, zoom: 7, cities: [
    { name: '沈阳', lng: 123.431, lat: 41.805 }, { name: '大连', lng: 121.614, lat: 38.914 },
    { name: '鞍山', lng: 122.994, lat: 41.108 }, { name: '抚顺', lng: 123.957, lat: 41.880 },
    { name: '本溪', lng: 123.766, lat: 41.294 }, { name: '丹东', lng: 124.354, lat: 40.000 },
    { name: '锦州', lng: 121.127, lat: 41.095 }, { name: '营口', lng: 122.235, lat: 40.667 },
    { name: '盘锦', lng: 122.070, lat: 41.119 }, { name: '葫芦岛', lng: 120.836, lat: 40.711 },
    { name: '朝阳', lng: 120.450, lat: 41.573 }, { name: '阜新', lng: 121.670, lat: 42.022 }
  ]},
  { name: '甘肃', lng: 103.826, lat: 36.059, zoom: 6, cities: [
    { name: '兰州', lng: 103.826, lat: 36.059 }, { name: '嘉峪关', lng: 98.289, lat: 39.773 },
    { name: '金昌', lng: 102.188, lat: 38.520 }, { name: '白银', lng: 104.137, lat: 36.544 },
    { name: '天水', lng: 105.724, lat: 34.580 }, { name: '武威', lng: 102.638, lat: 37.928 },
    { name: '张掖', lng: 100.455, lat: 38.932 }, { name: '平凉', lng: 106.665, lat: 35.542 },
    { name: '酒泉', lng: 98.494, lat: 39.732 }, { name: '庆阳', lng: 107.632, lat: 35.734 },
    { name: '定西', lng: 104.626, lat: 35.580 }, { name: '陇南', lng: 104.960, lat: 33.370 },
    { name: '敦煌', lng: 94.661, lat: 40.142 }
  ]},
  { name: '青海', lng: 96.780, lat: 35.620, zoom: 6, cities: [
    { name: '西宁', lng: 101.780, lat: 36.620 }, { name: '海东', lng: 102.103, lat: 36.502 },
    { name: '海北', lng: 100.901, lat: 36.959 }, { name: '黄南', lng: 102.019, lat: 35.519 },
    { name: '海南州', lng: 100.619, lat: 36.280 }, { name: '果洛', lng: 100.242, lat: 34.473 },
    { name: '玉树', lng: 97.008, lat: 33.004 }, { name: '海西', lng: 97.370, lat: 37.374 }
  ]},
  { name: '宁夏', lng: 106.258, lat: 37.471, zoom: 7, cities: [
    { name: '银川', lng: 106.258, lat: 38.471 }, { name: '石嘴山', lng: 106.376, lat: 39.013 },
    { name: '吴忠', lng: 106.198, lat: 37.986 }, { name: '固原', lng: 106.242, lat: 36.004 },
    { name: '中卫', lng: 105.189, lat: 37.514 }
  ]},
  { name: '内蒙古', lng: 114.765, lat: 43.817, zoom: 5, cities: [
    { name: '呼和浩特', lng: 111.765, lat: 40.817 }, { name: '包头', lng: 109.840, lat: 40.658 },
    { name: '乌海', lng: 106.825, lat: 39.673 }, { name: '赤峰', lng: 118.964, lat: 42.257 },
    { name: '通辽', lng: 122.256, lat: 43.613 }, { name: '鄂尔多斯', lng: 109.781, lat: 39.608 },
    { name: '呼伦贝尔', lng: 119.765, lat: 49.211 }, { name: '巴彦淖尔', lng: 107.416, lat: 40.757 },
    { name: '乌兰察布', lng: 113.132, lat: 41.019 }, { name: '锡林郭勒', lng: 116.042, lat: 43.933 }
  ]},
  { name: '新疆', lng: 85.627, lat: 41.793, zoom: 5, cities: [
    { name: '乌鲁木齐', lng: 87.627, lat: 43.793 }, { name: '克拉玛依', lng: 84.889, lat: 45.579 },
    { name: '吐鲁番', lng: 89.189, lat: 42.951 }, { name: '哈密', lng: 93.515, lat: 42.818 },
    { name: '昌吉', lng: 87.308, lat: 44.011 }, { name: '博尔塔拉', lng: 82.066, lat: 44.905 },
    { name: '巴音郭楞', lng: 86.110, lat: 41.764 }, { name: '阿克苏', lng: 80.260, lat: 41.168 },
    { name: '喀什', lng: 75.993, lat: 39.467 }, { name: '和田', lng: 79.922, lat: 37.114 },
    { name: '伊犁', lng: 81.324, lat: 43.916 }, { name: '塔城', lng: 82.980, lat: 46.745 }
  ]},
  { name: '西藏', lng: 89.117, lat: 30.644, zoom: 5, cities: [
    { name: '拉萨', lng: 91.117, lat: 29.644 }, { name: '日喀则', lng: 88.885, lat: 29.267 },
    { name: '昌都', lng: 97.172, lat: 31.140 }, { name: '林芝', lng: 94.361, lat: 29.649 },
    { name: '山南', lng: 91.773, lat: 29.239 }, { name: '那曲', lng: 92.052, lat: 31.476 },
    { name: '阿里', lng: 80.105, lat: 32.501 }
  ]},
  { name: '广西', lng: 108.366, lat: 23.817, zoom: 7, cities: [
    { name: '南宁', lng: 108.366, lat: 22.817 }, { name: '柳州', lng: 109.411, lat: 24.311 },
    { name: '桂林', lng: 110.290, lat: 25.273 }, { name: '梧州', lng: 111.279, lat: 23.476 },
    { name: '北海', lng: 109.119, lat: 21.481 }, { name: '防城港', lng: 108.353, lat: 21.687 },
    { name: '钦州', lng: 108.653, lat: 21.979 }, { name: '贵港', lng: 109.609, lat: 23.113 },
    { name: '玉林', lng: 110.180, lat: 22.636 }, { name: '百色', lng: 106.618, lat: 23.904 },
    { name: '贺州', lng: 111.567, lat: 24.403 }, { name: '河池', lng: 108.085, lat: 24.692 }
  ]},
  { name: '香港', lng: 114.165, lat: 22.275, zoom: 11, cities: [
    { name: '香港岛', lng: 114.165, lat: 22.275 }, { name: '九龙', lng: 114.174, lat: 22.315 },
    { name: '新界', lng: 114.155, lat: 22.380 }, { name: '大屿山', lng: 113.928, lat: 22.260 }
  ]},
  { name: '澳门', lng: 113.543, lat: 22.186, zoom: 12, cities: [
    { name: '澳门半岛', lng: 113.543, lat: 22.186 }, { name: '氹仔', lng: 113.560, lat: 22.158 },
    { name: '路环', lng: 113.566, lat: 22.116 }
  ]},
  { name: '台湾', lng: 120.960, lat: 23.697, zoom: 7, cities: [
    { name: '台北', lng: 121.509, lat: 25.044 }, { name: '高雄', lng: 120.312, lat: 22.627 },
    { name: '台中', lng: 120.673, lat: 24.147 }, { name: '台南', lng: 120.206, lat: 22.999 },
    { name: '新北', lng: 121.467, lat: 25.012 }, { name: '桃园', lng: 121.300, lat: 24.993 },
    { name: '基隆', lng: 121.747, lat: 25.132 }, { name: '新竹', lng: 120.967, lat: 24.813 },
    { name: '嘉义', lng: 120.449, lat: 23.480 }, { name: '花莲', lng: 121.601, lat: 23.987 },
    { name: '台东', lng: 121.145, lat: 22.756 }, { name: '宜兰', lng: 121.768, lat: 24.757 }
  ]}
];
// ==========================================
// 3. 自定义弹窗组件 (保持不变)
// ==========================================
@CustomDialog
struct CitySelectDialog {
  controller: CustomDialogController;
  @Link selectedNodes: NodeInfo[];
  confirm: (nodes: NodeInfo[]) => void = () => {};
  @State tempNodes: NodeInfo[] = [];

  aboutToAppear() {
    this.tempNodes = [...this.selectedNodes];
  }

  isSelected(city: NodeInfo): boolean {
    return this.tempNodes.some(n => n.name === city.name && n.lng === city.lng);
  }

  toggleCity(city: NodeInfo) {
    const index = this.tempNodes.findIndex(n => n.name === city.name && n.lng === city.lng);
    if (index !== -1) {
      this.tempNodes.splice(index, 1);
    } else {
      this.tempNodes.push(city);
    }
    this.tempNodes = [...this.tempNodes];
  }

  build() {
    Column() {
      Text("跨省城市选择器").fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 15, bottom: 10 })
      Divider().color('#EEE').width('90%')
      List() {
        ForEach(PROVINCE_DATA.slice(1), (prov: ProvinceDetail) => {
          ListItem() {
            Column({ space: 8 }) {
              Text(prov.name).fontSize(12).fontColor('#999').width('100%').textAlign(TextAlign.Start).padding({ left: 5, top: 10 })
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(prov.cities, (city: NodeInfo) => {
                  Text(city.name)
                    .fontSize(14)
                    .fontColor(this.isSelected(city) ? Color.White : '#333')
                    .backgroundColor(this.isSelected(city) ? '#2196F3' : '#F5F5F5')
                    .padding({ top: 6, bottom: 6, left: 12, right: 12 })
                    .borderRadius(4)
                    .margin({ right: 8, bottom: 8 })
                    .border({ width: 1, color: this.isSelected(city) ? '#2196F3' : '#E0E0E0' })
                    .onClick(() => { this.toggleCity(city); })
                })
              }.width('100%')
            }.width('100%').alignItems(HorizontalAlign.Start)
          }
        })
      }.width('100%').layoutWeight(1).padding({ left: 15, right: 15 }).edgeEffect(EdgeEffect.Spring)

      Row() {
        Button("取消").onClick(() => { this.controller.close(); }).backgroundColor('#F5F5F5').fontColor('#666').width('40%')
        Button(`确认 (${this.tempNodes.length})`).onClick(() => {
          this.selectedNodes = [...this.tempNodes];
          this.confirm(this.tempNodes);
          this.controller.close();
        }).backgroundColor('#2196F3').width('40%')
      }.width('100%').justifyContent(FlexAlign.SpaceEvenly).padding(15)
    }.width('90%').height('80%').backgroundColor(Color.White).borderRadius(12)
  }
}

// ==========================================
// 4. 主界面逻辑
// ==========================================


@Component
export struct RealMap {
  private readonly apiKey: string = "8d246873586b4ffb1bcc83af42772e0e";

  @State longitude: number = 105.000;
  @State latitude: number = 35.000;
  @State zoom: number = 4;
  @State mapUrl: string = "";

  @State isCustomMode: boolean = false;
  @State currentProvinceIndex: number = 0;
  @State visibleNodes: NodeInfo[] = [];

  @State customNodePool: NodeInfo[] = [];
  @State mstEdgesToDraw: GraphEdge[] = [];
  @State activeEdge: GraphEdge | null = null;

  @State visualScale: number = 1;
  @State visualOffsetX: number = 0;
  @State visualOffsetY: number = 0;
  private lastOffsetX: number = 0;
  private lastOffsetY: number = 0;
  private lastScale: number = 1;

  private canvasSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSettings);
  @State canvasWidth: number = 0;
  @State canvasHeight: number = 0;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CitySelectDialog({
      selectedNodes: $customNodePool,
      confirm: (nodes) => {
        this.customNodePool = nodes;
        this.mstEdgesToDraw = [];
        this.activeEdge = null;
        this.drawCanvas();
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  });

  aboutToAppear() {
    this.updateVisibleNodes();
    this.refreshMap();
  }

  // -------------------------
  // 逻辑控制
  // -------------------------

  switchProvince(index: number) {
    if (!PROVINCE_DATA[index]) return;
    this.currentProvinceIndex = index;
    const target = PROVINCE_DATA[index];
    this.longitude = target.lng;
    this.latitude = target.lat;
    this.zoom = target.zoom;

    if (!this.isCustomMode) {
      this.mstEdgesToDraw = [];
      this.activeEdge = null;
    }

    this.updateVisibleNodes();
    this.resetVisual();
    this.refreshMap();
    this.drawCanvas();
  }

  updateVisibleNodes() {
    if (this.currentProvinceIndex === 0) {
      this.visibleNodes = JSON.parse(JSON.stringify(PROVINCE_DATA.slice(1))) as NodeInfo[];
    } else {
      const cities = PROVINCE_DATA[this.currentProvinceIndex].cities;
      this.visibleNodes = cities ? JSON.parse(JSON.stringify(cities)) as NodeInfo[] : [];
    }
  }

  handleNodeClick(node: NodeInfo) {
    if (this.currentProvinceIndex === 0) {
      const provinceName = node.name;
      const realIndex = PROVINCE_DATA.findIndex(p => p.name === provinceName);
      if (realIndex !== -1) this.switchProvince(realIndex);
      return;
    }
  }

  toggleMode(isCustom: boolean) {
    this.isCustomMode = isCustom;
    this.mstEdgesToDraw = [];
    this.activeEdge = null;
    this.drawCanvas();
  }

  resetVisual() {
    this.visualOffsetX = 0;
    this.visualOffsetY = 0;
    this.visualScale = 1;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.lastScale = 1;
  }

  refreshMap() {
    const locStr = `${this.longitude.toFixed(6)},${this.latitude.toFixed(6)}`;
    const baseUrl = "https://restapi.amap.com/v3/staticmap";
    const size = "1024*1024";
    this.mapUrl = `${baseUrl}?location=${locStr}&zoom=${this.zoom}&size=${size}&scale=2&key=${this.apiKey}`;
    setTimeout(() => { this.drawCanvas(); }, 100);
  }

  drawCanvas() {
    if (!this.context) return;
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    let activeNodes: NodeInfo[] = [];
    if (this.isCustomMode) {
      activeNodes = this.customNodePool;
    } else if (this.currentProvinceIndex !== 0) {
      activeNodes = this.visibleNodes;
    }

    if (activeNodes.length === 0) return;

    const lineWidth = 3 / this.visualScale;
    this.context.lineCap = 'round';

    this.context.beginPath();
    this.context.strokeStyle = '#4096FF';
    this.context.lineWidth = lineWidth;
    this.mstEdgesToDraw.forEach(edge => {
      if (this.activeEdge && edge.from === this.activeEdge.from && edge.to === this.activeEdge.to) return;
      if (edge.from >= activeNodes.length || edge.to >= activeNodes.length) return;

      const u = activeNodes[edge.from];
      const v = activeNodes[edge.to];
      const start = Projection.convertLatLngToPixel(u.lat, u.lng, this.latitude, this.longitude, this.zoom, this.canvasWidth, this.canvasHeight);
      const end = Projection.convertLatLngToPixel(v.lat, v.lng, this.latitude, this.longitude, this.zoom, this.canvasWidth, this.canvasHeight);
      this.context.moveTo(start.x, start.y);
      this.context.lineTo(end.x, end.y);
    });
    this.context.stroke();

    if (this.activeEdge) {
      const u = activeNodes[this.activeEdge.from];
      const v = activeNodes[this.activeEdge.to];
      const start = Projection.convertLatLngToPixel(u.lat, u.lng, this.latitude, this.longitude, this.zoom, this.canvasWidth, this.canvasHeight);
      const end = Projection.convertLatLngToPixel(v.lat, v.lng, this.latitude, this.longitude, this.zoom, this.canvasWidth, this.canvasHeight);

      this.context.beginPath();
      this.context.strokeStyle = '#FF0000';
      this.context.lineWidth = lineWidth * 2.5;
      this.context.moveTo(start.x, start.y);
      this.context.lineTo(end.x, end.y);
      this.context.stroke();
    }

    const radius = 6 / this.visualScale;

    if (this.isCustomMode && this.currentProvinceIndex !== 0) {
      this.visibleNodes.forEach(node => {
        const inPool = this.customNodePool.some(n => n.name === node.name && n.lng === node.lng);
        if (inPool) return;
        const pos = Projection.convertLatLngToPixel(node.lat, node.lng, this.latitude, this.longitude, this.zoom, this.canvasWidth, this.canvasHeight);
        this.context.beginPath();
        this.context.arc(pos.x, pos.y, radius, 0, 6.28);
        this.context.strokeStyle = '#999';
        this.context.lineWidth = 1;
        this.context.stroke();
      });
    }

    activeNodes.forEach((node, index) => {
      const pos = Projection.convertLatLngToPixel(node.lat, node.lng, this.latitude, this.longitude, this.zoom, this.canvasWidth, this.canvasHeight);

      this.context.beginPath();
      this.context.arc(pos.x, pos.y, radius, 0, 6.28);

      let isHighlight = false;
      if (this.activeEdge && (index === this.activeEdge.from || index === this.activeEdge.to)) {
        isHighlight = true;
      }

      if (isHighlight) {
        this.context.fillStyle = '#FF0000';
        this.context.shadowBlur = 10;
        this.context.shadowColor = '#FF0000';
      } else {
        this.context.fillStyle = this.isCustomMode ? '#FF9800' : '#008000';
        this.context.shadowBlur = 0;
      }
      this.context.fill();
      this.context.shadowBlur = 0;

      if (this.visualScale > 0.8) {
        this.context.fillStyle = '#333';
        this.context.font = 'bold 12px sans-serif';
        this.context.fillText(node.name, pos.x + radius + 2, pos.y + 4);
      }
    });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {

      // 1. 地图层
      Stack() {
        Image(this.mapUrl).objectFit(ImageFit.Cover).width('100%').height('100%').backgroundColor('#E0E0E0')
        Canvas(this.context).width('100%').height('100%').hitTestBehavior(HitTestMode.None)
          .onAreaChange((o, n) => {
            this.canvasWidth = parseInt(n.width.toString());
            this.canvasHeight = parseInt(n.height.toString());
            this.drawCanvas();
          })
      }
      .width('100%').height('100%')
      .scale({ x: this.visualScale, y: this.visualScale })
      .translate({ x: this.visualOffsetX, y: this.visualOffsetY })
      .animation({ duration: 0 })
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture({ fingers: 1 })
            .onActionUpdate((event?: GestureEvent) => {
              if (event) {
                this.visualOffsetX = this.lastOffsetX + event.offsetX;
                this.visualOffsetY = this.lastOffsetY + event.offsetY;
              }
            })
            .onActionEnd((event?: GestureEvent) => {
              if (event) {
                const sensitivity = 0.000008 * Math.pow(2, 17 - this.zoom);
                if (Math.abs(event.offsetX) > 10 || Math.abs(event.offsetY) > 10) {
                  this.longitude -= event.offsetX * sensitivity;
                  this.latitude += event.offsetY * sensitivity;
                  this.visualOffsetX = 0; this.visualOffsetY = 0;
                  this.lastOffsetX = 0; this.lastOffsetY = 0;
                  this.refreshMap();
                }
              }
            }),
          PinchGesture({ fingers: 2 })
            .onActionUpdate((event?: GestureEvent) => {
              if (event) {
                let s = this.lastScale * event.scale;
                if (s > 0.5 && s < 3) this.visualScale = s;
              }
            })
            .onActionEnd((event?: GestureEvent) => {
              if (event) {
                let newZoom = this.zoom + (this.visualScale > 1.3 ? 1 : (this.visualScale < 0.7 ? -1 : 0));
                if (newZoom < 4) newZoom = 4;
                if (newZoom > 17) newZoom = 17;
                if (newZoom !== this.zoom) {
                  this.zoom = newZoom;
                  this.visualScale = 1;
                  this.refreshMap();
                } else {
                  animateTo({ duration: 200 }, () => { this.visualScale = 1; });
                }
              }
            })
        )
      )

      // 2. 顶部导航栏 (【优化】字体改黑，阴影改白)
      Column() {
        Row() {
          Text("模式：")
            .fontSize(14)
            .fontColor(Color.Black) // 【修改】黑色字体
            .shadow({ radius: 3, color: Color.White }) // 【修改】白色阴影，增强对比度
          Row() {
            Button("省内生成树")
              .type(ButtonType.Normal)
              .backgroundColor(this.isCustomMode ? '#88000000' : '#2196F3')
              .onClick(() => this.toggleMode(false))
              .borderRadius({ topLeft: 15, bottomLeft: 15 })
              .height(30).fontSize(12)
            Button("跨省自定义")
              .type(ButtonType.Normal)
              .backgroundColor(this.isCustomMode ? '#2196F3' : '#88000000')
              .onClick(() => this.toggleMode(true))
              .borderRadius({ topRight: 15, bottomRight: 15 })
              .height(30).fontSize(12)
          }
        }
        .width('100%').justifyContent(FlexAlign.Center).padding({ top: 40 })

        Row() {
          Text(this.currentProvinceIndex === 0 ? "视图：全国" : `视图：${PROVINCE_DATA[this.currentProvinceIndex].name}`)
            .fontSize(14)
            .fontColor(Color.Black) // 【修改】黑色字体
            .shadow({ radius: 3, color: Color.White }) // 【修改】白色阴影

          Blank()

          Select(PROVINCE_DATA.map(p => { return { value: p.name } as SelectOption }))
            .selected(this.currentProvinceIndex)
            .value(PROVINCE_DATA[this.currentProvinceIndex].name)
            .font({ size: 12 }).fontColor(Color.White)
            .backgroundColor('#AA007DFF').borderRadius(8)
            .onSelect((index: number) => { this.switchProvince(index); })
            .height(30).width(80)
        }
        .width('100%').padding({ left: 20, right: 20, top: 10 })
      }
      .position({ x: 0, y: 0 }).hitTestBehavior(HitTestMode.None)

      // 3. 底部区域 (智能切换)
      if (this.isCustomMode) {
        Column() {
          Row() {
            Text(`已选城市 (${this.customNodePool.length})`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
            Blank()
            Button("＋ 选择城市")
              .fontSize(12)
              .height(28)
              .backgroundColor('#2196F3')
              .onClick(() => {
                this.dialogController.open();
              })
          }.width('100%').padding({ left: 10, right: 10, top: 10, bottom: 5 })

          List({ space: 8, initialIndex: 0 }) {
            ForEach(this.customNodePool, (node: NodeInfo) => {
              ListItem() {
                Text(node.name).fontSize(12).fontColor('#2196F3').backgroundColor('#E3F2FD').padding({left:8, right:8, top:4, bottom:4}).borderRadius(12)
              }
            })
          }.listDirection(Axis.Horizontal).height(30).width('100%').padding({ left: 10 }).scrollBar(BarState.Off)

          AlgorithmPanel({
            nodes: this.customNodePool,
            // 【新增】传入当前范围名称
            currentScopeName: "自定义区域",
            onEdgesUpdate: (edges: GraphEdge[], latestEdge: GraphEdge | null) => {
              this.mstEdgesToDraw = edges;
              this.activeEdge = latestEdge;
              this.drawCanvas();
            }
          })
        }
        .width('95%')
        .backgroundColor(Color.White).borderRadius(10)
        .margin({ bottom: 20, left: 10, right: 10 })
        .padding(5)

      } else {
        if (this.currentProvinceIndex === 0) {
          List() {
            ForEach(this.visibleNodes, (node: NodeInfo, index: number) => {
              ListItem() {
                Row() {
                  Text("→").fontSize(14).fontColor(Color.Gray).margin({ right: 8 })
                  Text(node.name).fontSize(16)
                }
                .width('100%').padding(12).backgroundColor(Color.White).border({ width: { bottom: 1 }, color: '#EEE' })
                .onClick(() => { this.handleNodeClick(node); })
              }
            })
          }
          .width('95%').height(180).backgroundColor(Color.White).borderRadius(10).margin({ bottom: 20 })
        } else {
          Column() {
            AlgorithmPanel({
              nodes: this.visibleNodes,
              // 【新增】传入省份名称
              currentScopeName: PROVINCE_DATA[this.currentProvinceIndex].name,
              onEdgesUpdate: (edges: GraphEdge[], latestEdge: GraphEdge | null) => {
                this.mstEdgesToDraw = edges;
                this.activeEdge = latestEdge;
                this.drawCanvas();
              }
            })
          }
          .width('95%').backgroundColor(Color.White).borderRadius(10).margin({ bottom: 20, left: 10, right: 10 })
        }
      }
    }
    .width('100%').height('100%').backgroundColor('#F0F0F0')
  }
}