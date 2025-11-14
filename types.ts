export enum Side {
  A = 'A',
  B = 'B',
}

export enum EndReason {
  IN = 'IN',
  OUT = 'OUT',
  NET = 'NET',
  FAULT_SERVE = 'FAULT_SERVE',
  LET = 'LET',
  MANUAL = 'MANUAL',
}

export enum ServingCourt {
  LEFT = 'LEFT',
  RIGHT = 'RIGHT',
}

export interface Rally {
  rallyId: string;
  serverSide: Side;
  winnerSide: Side | null;
  endReason: EndReason | null;
  isManualOverride: boolean;
}

export interface Game {
  gameIndex: number;
  scoreA: number;
  scoreB: number;
  rallies: Rally[];
  winner: Side | null;
  isComplete: boolean;
}

export interface Match {
  matchId: string;
  playerA: string;
  playerB: string;
  bestOf: 3 | 5;
  games: Game[];
  winner: Side | null;
  isComplete: boolean;
  server: Side;
}

export interface AiSuggestion {
  winner_side: Side;
  end_reason: EndReason;
  playerTrackingNote?: string;
}