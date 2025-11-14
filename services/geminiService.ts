import { GoogleGenAI, Type } from "@google/genai";
import { Side, EndReason, AiSuggestion, Match, Game } from '../types';

const API_KEY = process.env.API_KEY;

if (!API_KEY) {
  console.warn("API_KEY environment variable not set. AI features will be disabled.");
}

const ai = new GoogleGenAI({ apiKey: API_KEY });

export const simulateRally = async (matchState: Match): Promise<AiSuggestion | null> => {
  if (!API_KEY) {
    // Fallback for when API key is not available
    console.log("Simulating rally locally due to missing API key.");
    const winner = Math.random() > 0.5 ? Side.A : Side.B;
    const reasons = [EndReason.IN, EndReason.OUT, EndReason.NET];
    const reason = reasons[Math.floor(Math.random() * reasons.length)];
    const notes = [
        `Player ${winner === Side.A ? 'B' : 'A'} was caught off-guard by a drop shot.`,
        `Player ${winner} dominated the net with an aggressive stance.`,
        `Player ${winner === Side.A ? 'B' : 'A'} was too slow to react to a deep court smash.`
    ];
    const note = notes[Math.floor(Math.random() * notes.length)];
    return Promise.resolve({ winner_side: winner, end_reason: reason, playerTrackingNote: note });
  }
  
  const currentGame = matchState.games[matchState.games.length - 1];

  const prompt = `
    You are a badminton match simulator. Your task is to predict the outcome of the next rally.
    Current Match State:
    - Player A (${matchState.playerA}) vs Player B (${matchState.playerB})
    - Best of ${matchState.bestOf} games.
    - Current Game Score: ${matchState.playerA} ${currentGame.scoreA} - ${currentGame.scoreB} ${matchState.playerB}
    - Serving Player: Player ${matchState.server} (${matchState.server === Side.A ? matchState.playerA : matchState.playerB})
    - Games Won: ${matchState.playerA}: ${matchState.games.filter(g => g.winner === Side.A).length}, ${matchState.playerB}: ${matchState.games.filter(g => g.winner === Side.B).length}

    Based on this state, determine the winner of the next rally and a plausible reason for the rally ending.
    Also, provide a brief "playerTrackingNote" that describes player positioning or movement that contributed to the outcome (e.g., "Player A was out of position," "Player B executed a powerful smash from the net").
    The reason must be one of: IN, OUT, NET, FAULT_SERVE.
    Provide your response ONLY in the specified JSON format.
  `;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            winner_side: { 
              type: Type.STRING,
              enum: [Side.A, Side.B],
              description: 'The player who won the rally (A or B).'
            },
            end_reason: { 
              type: Type.STRING,
              enum: [EndReason.IN, EndReason.OUT, EndReason.NET, EndReason.FAULT_SERVE],
              description: 'The reason the rally ended.'
            },
            playerTrackingNote: {
              type: Type.STRING,
              description: 'A brief note on player tracking/positioning that influenced the rally outcome.'
            }
          },
          required: ["winner_side", "end_reason"],
        },
      },
    });

    const jsonString = response.text.trim();
    const result = JSON.parse(jsonString) as AiSuggestion;
    return result;
  } catch (error) {
    console.error("Error calling Gemini API:", error);
    // Fallback to local simulation on API error
    return simulateRally(matchState);
  }
};