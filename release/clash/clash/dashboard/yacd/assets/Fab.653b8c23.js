var B=Object.defineProperty,H=Object.defineProperties;var L=Object.getOwnPropertyDescriptors;var p=Object.getOwnPropertySymbols;var N=Object.prototype.hasOwnProperty,$=Object.prototype.propertyIsEnumerable;var k=(t,s,n)=>s in t?B(t,s,{enumerable:!0,configurable:!0,writable:!0,value:n}):t[s]=n,o=(t,s)=>{for(var n in s||(s={}))N.call(s,n)&&k(t,n,s[n]);if(p)for(var n of p(s))$.call(s,n)&&k(t,n,s[n]);return t},r=(t,s)=>H(t,L(s));var d=(t,s)=>{var n={};for(var e in t)N.call(t,e)&&s.indexOf(e)<0&&(n[e]=t[e]);if(t!=null&&p)for(var e of p(t))s.indexOf(e)<0&&$.call(t,e)&&(n[e]=t[e]);return n};import{j as i,b as v,r as b,h as R}from"./index.25cbb458.js";const V="_spining_4i8sg_1",q="_spining_keyframes_4i8sg_1";var w={spining:V,spining_keyframes:q};const{useState:z}=R;function Q({children:t}){return i("span",{className:w.spining,children:t})}const S={right:10,bottom:10},U=n=>{var e=n,{children:t}=e,s=d(e,["children"]);return i("button",r(o({type:"button"},s),{className:"rtf--ab",children:t}))},D=n=>{var e=n,{children:t}=e,s=d(e,["children"]);return i("button",r(o({type:"button",className:"rtf--mb"},s),{children:t}))},G={bottom:24,right:24},W=J=>{var h=J,{event:t="hover",style:s=G,alwaysShowTitle:n=!1,children:e,icon:C,mainButtonStyles:I,onClick:f,text:g}=h,y=d(h,["event","style","alwaysShowTitle","children","icon","mainButtonStyles","onClick","text"]);const[l,u]=z(!1),m=n||!l,_=()=>u(!0),x=()=>u(!1),F=()=>t==="hover"&&_(),M=()=>t==="hover"&&x(),j=a=>f?f(a):(a.persist(),t==="click"?l?x():_():null),E=(a,c)=>{a.persist(),u(!1),setTimeout(()=>{c(a)},1)},O=()=>b.exports.Children.map(e,(a,c)=>b.exports.isValidElement(a)?v("li",{className:`rtf--ab__c ${"top"in s?"top":""}`,children:[b.exports.cloneElement(a,r(o({"data-testid":`action-button-${c}`,"aria-label":a.props.text||`Menu button ${c+1}`,"aria-hidden":m,tabIndex:l?0:-1},a.props),{onClick:A=>{a.props.onClick&&E(A,a.props.onClick)}})),a.props.text&&i("span",{className:`${"right"in s?"right":""} ${n?"always-show":""}`,"aria-hidden":m,children:a.props.text})]}):null);return i("ul",r(o({onMouseEnter:F,onMouseLeave:M,className:`rtf ${l?"open":"closed"}`,"data-testid":"fab",style:s},y),{children:v("li",{className:"rtf--mb__c",children:[i(D,{onClick:j,style:I,"data-testid":"main-button",role:"button","aria-label":"Floating menu",tabIndex:0,children:C}),g&&i("span",{className:`${"right"in s?"right":""} ${n?"always-show":""}`,"aria-hidden":m,children:g}),i("ul",{children:O()})]})}))};export{U as A,W as F,Q as I,S as p};
