import React, { useState, useCallback } from "react";
import ChatMessages from "./ChatMessages";
import ChatInput from "./ChatInput";
import useChannel from "../../hooks/useChannel";
import useIsLoggedIn from "../../hooks/useIsLoggedIn";
import { ChatMessage } from "elixir-backend";

interface Props {
  chatBroadcast: (eventName: string, payload: object) => void;
  messages: Array<ChatMessage>;
}

export const Chat: React.FC<Props> = ({ chatBroadcast, messages }) => {
  const isLoggedIn = useIsLoggedIn();

  return (

    <div className="overflow-hidden h-full">
      <div className="bg-gray-800 overflow-y-auto rounded-lg" style={{height: "calc(100% - 32px)"}}>
        <ChatMessages messages={messages}/>
      </div>
      <div className="text-center" >
        {isLoggedIn && <ChatInput chatBroadcast={chatBroadcast} />}
      </div>
    </div>
  );
};
export default Chat;
