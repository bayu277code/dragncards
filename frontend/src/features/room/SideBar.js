import React from "react";
import { SideBarPhase } from "./SideBarPhase";

export const SideBar = React.memo(({
  playerN,
  gameBroadcast,
  chatBroadcast,
}) => {
  return(
    <div className="bg-gray-500" style={{width:"48px", zIndex: 1e6}}>
      <SideBarPhase
        playerN={playerN}
        phase={"Start"}
        text={"α"}
        height={"4%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "0.0": "0.0: Beginning of the round",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Resource"}
        text={"Resource"}
        height={"11%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "1.1": "1.1: Beginning of the Resource phase",
          "1.R": "1.2 & 1.3: Gain resources and draw cards",
          "1.4": "1.4: End of the Resource phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Planning"}
        text={"Planning"}
        height={"11%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "2.1": "2.1: Beginning of the Planning phase",
          "2.P": "2.2 & 2.3: Play cards in turn order",
          "2.4": "2.4: End of the Planning phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Quest"}
        text={"Quest"}
        height={"17%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "3.1": "3.1: Beginning of the Quest phase",
          "3.2": "3.2: Commit characters to the quest",
          "3.3": "3.3: Staging",
          "3.4": "3.4: Quest resolution",
          "3.5": "3.5: End of the Quest phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Travel"}
        text={"Travel"}
        height={"11%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "4.1": "4.1: Beginning of the Travel phase",
          "4.2": "4.2: Travel opportunity",
          "4.3": "4.3: End of the Travel phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Encounter"}
        text={"Encounter"}
        height={"14%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "5.1": "5.1: Beginning of the Encounter phase",
          "5.2": "5.2: Optional engagement",
          "5.3": "5.3: Engagement checks",
          "5.4": "5.4: End of the Encounter phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Combat"}
        text={"Combat"}
        height={"17%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "6.1": "6.1: Beginning of the Combat phase",
          "6.2": "6.2: Deal shadow cards",
          "6.E": "6.3-6.6: Enemy attacks",
          "6.P": "6.7-6.10: Player attacks",
          "6.11": "6.11: End of the Combat phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"Refresh"}
        text={"Refresh"}
        height={"11%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "7.1": "7.1: Beginning of the Refresh phase",
          "7.R": "7.2-7.4: Ready cards, raise threat, pass P1 token",
          "7.3": "7.3: End of the Refresh phase",
        }}
      />
      <SideBarPhase
        playerN={playerN}
        phase={"End"}
        text={"Ω"}
        height={"4%"}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        phaseInfo={{
          "0.1": "0.1: End of the round",
        }}
      />
    </div>
  )
})
