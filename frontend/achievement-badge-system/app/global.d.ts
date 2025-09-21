import React from "react";

declare global {
  namespace JSX {
    interface IntrinsicElements {
      "w3m-button": React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement>;
      "w3m-network-button": React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement>;
      "appkit-button": React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement>;
      "appkit-connect-button": React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement>;
      "appkit-account-button": React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement>;
      "appkit-network-button": React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement>;
    }
  }
}