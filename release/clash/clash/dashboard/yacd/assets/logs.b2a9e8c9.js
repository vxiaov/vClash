var $=Object.defineProperty,k=Object.defineProperties;var y=Object.getOwnPropertyDescriptors;var h=Object.getOwnPropertySymbols;var E=Object.prototype.hasOwnProperty,A=Object.prototype.propertyIsEnumerable;var S=(e,t,n)=>t in e?$(e,t,{enumerable:!0,configurable:!0,writable:!0,value:n}):e[t]=n,b=(e,t)=>{for(var n in t||(t={}))E.call(t,n)&&S(e,n,t[n]);if(h)for(var n of h(t))A.call(t,n)&&S(e,n,t[n]);return e},v=(e,t)=>k(e,y(t));import{A as O,D as R,E as u}from"./index.25cbb458.js";const L="/logs",x=new TextDecoder("utf-8"),F=()=>Math.floor((1+Math.random())*65536).toString(16);let p=!1,i=!1,f="",s,g;function m(e,t){let n;try{n=JSON.parse(e)}catch{console.log("JSON.parse error",JSON.parse(e))}const r=new Date,l=H(r);n.time=l,n.id=+r-0+F(),n.even=p=!p,t(n)}function H(e){const t=e.getFullYear()%100,n=u(e.getMonth()+1,2),r=u(e.getDate(),2),l=u(e.getHours(),2),o=u(e.getMinutes(),2),c=u(e.getSeconds(),2);return`${t}-${n}-${r} ${l}:${o}:${c}`}function M(e,t){return e.read().then(({done:n,value:r})=>{f+=x.decode(r,{stream:!n});const o=f.split(`
`),c=o[o.length-1];for(let d=0;d<o.length-1;d++)m(o[d],t);if(n){m(c,t),f="",console.log("GET /logs streaming done"),i=!1;return}else f=c;return M(e,t)})}function D(e){const t=Object.keys(e);return t.sort(),t.map(n=>e[n]).join("|")}let w,a;function J(e,t){if(e.logLevel==="uninit"||i||s&&s.readyState===1)return;g=t;const n=O(e,L);s=new WebSocket(n),s.addEventListener("error",()=>{N(e,t)}),s.addEventListener("message",function(r){m(r.data,t)})}function Y(){s.close(),a&&a.abort()}function j(e){!g||!s||(s.close(),i=!1,J(e,g))}function N(e,t){if(a&&D(e)!==w)a.abort();else if(i)return;i=!0,w=D(e),a=new AbortController;const n=a.signal,{url:r,init:l}=R(e);fetch(r+L+"?level="+e.logLevel,v(b({},l),{signal:n})).then(o=>{const c=o.body.getReader();M(c,t)},o=>{i=!1,!n.aborted&&console.log("GET /logs error:",o.message)})}export{J as f,j as r,Y as s};
