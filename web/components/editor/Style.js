const Style = (props) => {
  return (
    <style
      dangerouslySetInnerHTML={{
        __html: props.css,
      }}
    />
  );
};

export default Style;
