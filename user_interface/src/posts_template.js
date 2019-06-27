import React from 'react';
import { SelectInput, Edit, TextInput, TabbedForm, FormTab, DateInput, TextField , List, Datagrid, Toolbar, SaveButton} from 'react-admin';
import RichTextInput from 'ra-input-rich-text';

// Methods
const headerStyle= {
    backgroundColor: "#2196f3",
    padding: "1px 15px",
    color: "white",
    opacity: .6,
    boxShadow: `1.5px 3px 1.5px lightgrey`
};

const progressStyle = (progress) => ({
    width: progress,
    height: "15px",
    backgroundColor: "forestgreen",
    opacity: .7,
});

const wrapperStyle = {
    height: "15px",
    width: "50%",
    backgroundColor: "#e2e2e2"
};

const PostTitle = ({ record }) => {
    return <span>{record.id}</span>;
};

const Header = ({ header, caption }) => {
    return(<div style={headerStyle}><h3>{header}</h3><em>{caption}</em></div>);
}

const ProgressBar = ({ source, record = {} }) => {
    const progress = record[source]*100+"%";
    return(<div style={wrapperStyle}>
              <div style={progressStyle(progress)}></div>
           </div>);
}

const Space = ({ }) => {
  return(<div><br></br><br></br></div>);
}

const PostEditToolbar = props => (
    <Toolbar {...props} >
        <SaveButton
            undoable={false}
        />
    </Toolbar>
);

export const PostList = props => (
    <List bulkActions={false} exporter={false} {...props}>
        <Datagrid rowClick="edit">
            <TextField source="id" label="Unit of Analysis" />
            <ProgressBar source="Progress" />
            <TextField source="Last Update" />
        </Datagrid>
    </List>
);


// Main Application
export const PostEdit = (props) => (
    <Edit title={<PostTitle />} undoable={false} {...props}>
        <TabbedForm toolbar={<PostEditToolbar />}>
            <FormTab label="Coding">
                XXXXX
            </FormTab>
            <FormTab label="Notes">
                <RichTextInput source="body" />
            </FormTab>
        </TabbedForm>
    </Edit>
);
