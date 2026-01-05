// entry/src/main/ets/models/Graph.ts

export interface NodeInfo {
  name: string;
  lng: number;
  lat: number;
}

export interface GraphEdge {
  from: number; // 节点在数组中的索引
  to: number;   // 节点在数组中的索引
  weight: number;
}

// 动画步骤类型
export type StepType = 'check' | 'select' | 'reject' | 'complete' | 'init';

export interface AnimationStep {
  type: StepType;
  message: string;
  edge?: GraphEdge;
  edgesSoFar: GraphEdge[]; // 这一步对应的所有已连接边
  costSoFar: number;
}