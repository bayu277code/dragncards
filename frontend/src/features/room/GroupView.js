import React, { Component } from "react";
import styled from "@emotion/styled";
import Stacks from "./Stacks";
import Title from "./Title";
import { GROUPSINFO } from "./Constants";
import { faChevronDown } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { ContextMenu, MenuItem, SubMenu, ContextMenuTrigger } from "react-contextmenu";
import { handleBrowseTopN } from "./HandleBrowseTopN";
import { GroupContextMenu } from "./GroupContextMenu";

const Container = styled.div`
  padding: 1px 1px 1px 1px;
  max-height: 100%;
  height: 100%;
  width: 100%;
`;

const Header = styled.div`
  align-items: center;
  justify-content: center;
  color: white;
  height: 13%;
`;

const WidthContainer = styled.div`
  padding: 2px 2px 2px 0.5vw;
  float: left;
  height: 100%;
`;

const GroupComponent = React.memo(({
  group,
  gameBroadcast,
  chatBroadcast,
  showTitle,
  setBrowseGroupID,
  setBrowseGroupTopN,
}) => {


  const numStacks = group["stacks"].length;
  return(
    <Container>
      <ContextMenuTrigger id={group.id} holdToDisplay={0}>
        <Header>
          <Title>{group.name} <FontAwesomeIcon className="text-white" icon={faChevronDown}/></Title>
        </Header>
      </ContextMenuTrigger> 

      <GroupContextMenu
        group={group}
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        setBrowseGroupID={setBrowseGroupID}
        setBrowseGroupTopN={setBrowseGroupTopN}
      ></GroupContextMenu>
      
      <Stacks
        gameBroadcast={gameBroadcast}
        chatBroadcast={chatBroadcast}
        group={group}
        isCombineEnabled={group.type === "play"}
        selectedStackIndices={[...Array(numStacks).keys()]}
      />
    </Container>
  )


})

export class GroupView extends Component {

  shouldComponentUpdate = (nextProps, nextState) => {
        // if (nextProps.group.id == "gSharedStaging") {
        //   console.log("prev",JSON.stringify(this.props.group.stacks[0].cards[0].exhausted),JSON.stringify(this.props.group.stacks[1].cards[0].exhausted))
        //   console.log("next",JSON.stringify(nextProps.group.stacks[0].cards[0].exhausted),JSON.stringify(nextProps.group.stacks[1].cards[0].exhausted))
        // }
              //if (nextProps.group.updated === false) {
      if (JSON.stringify(nextProps.group)===JSON.stringify(this.props.group)) {

        return false;
//      } else if {

      } else {
        // console.log('this.props.group');
        // console.log(this.props.group);
        // console.log('nextProps.group');
        // console.log(nextProps.group);
        return true;
      }
  };

  render() {
    const group = this.props.group;
    if (group) {
      console.log('rendering',group.id);
      return (
        // <Draggable draggableId={title} index={index}>
        //   {(provided, snapshot) => (ref={provided.innerRef} {...provided.draggableProps}>

        <GroupComponent
          group={this.props.group}
          gameBroadcast={this.props.gameBroadcast}
          chatBroadcast={this.props.chatBroadcast}
          showTitle={this.props.showTitle}
          setBrowseGroupID={this.props.setBrowseGroupID}
          setBrowseGroupTopN={this.props.setBrowseGroupTopN}
        ></GroupComponent>

        //   )}
        // </Draggable>
      );

    } else {
      return (<div></div>)
    }
  }
}

export class GroupContainer extends Component {
  render() {
    if (this.props.group) {
      const beingBrowsed = this.props.browseGroupID === this.props.group.id;
      return (
        <WidthContainer 
          style={{
            width: this.props.width, 
            visibility: beingBrowsed ? "hidden" : "visible"
          }}>
          {beingBrowsed? <div></div> :
            <div style={{width:"100%", height:"100%"}}>
              <GroupView 
                group={this.props.group} 
                gameBroadcast={this.props.gameBroadcast} 
                chatBroadcast={this.props.chatBroadcast}
                setBrowseGroupID={this.props.setBrowseGroupID}
                setBrowseGroupTopN={this.props.setBrowseGroupTopN}
              ></GroupView>
            </div>
          }

        </WidthContainer>
      )
    } else {
      return (<div></div>)
    }
  }
}